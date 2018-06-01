//
//  LoanAvailable.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanAvailable: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_AMORTIZATIONS = "amortizations"
    private let KEY_ASSESSMENT = "assessment"
    private let KEY_FREQUENCIES = "frequencies"
    private let KEY_LOAN_CAP = "loan_cap"

    var amortizations: [LoanAmortization]?
    var assessment: AssessmentInfo?
    var frequencies: [LoanFrequency]?
    var loanCap: Float?

    var description: String {
        return "LoanAvailable [ loan cap : \(loanCap ?? -1) , assessment : \(assessment?.description ?? "nil") , amortizations : \(amortizations?.count ?? -1) , frequencies : \(frequencies?.count ?? -1) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    func isValid() -> Bool {
        return amortizations != nil && amortizations!.count > 0 && assessment != nil && assessment!.isValid() && assessment!.isValidRate() && frequencies != nil && frequencies!.count > 0 && loanCap != nil && loanCap! >= 0.0
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let amortizationsJson = json.object(forKey: KEY_AMORTIZATIONS) as? NSArray,
                let assessmentJson = json.object(forKey: KEY_ASSESSMENT) as? NSDictionary,
                let frequenciesJson = json.object(forKey: KEY_FREQUENCIES) as? NSArray,
                let loanCapNum = json.object(forKey: KEY_LOAN_CAP) as? NSNumber {

                self.amortizations = LoanAmortization.parseArray(amortizationsJson)
                self.assessment = AssessmentInfo.init(assessmentJson)
                self.frequencies = LoanFrequency.parseArray(frequenciesJson)
                self.loanCap = loanCapNum.floatValue
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            // Amortizations
            let amortizationArray = NSMutableArray.init()
            for amortization in amortizations! {
                if amortization.isValid() {
                    amortizationArray.add(amortization.toJson()!)
                }
            }

            // Frequencies
            let frequencyArray = NSMutableArray.init()
            for frequency in frequencies! {
                if frequency.isValid() {
                    frequencyArray.add(frequency.toJson()!)
                }
            }

            // Return with all data
            return [
                KEY_LOAN_CAP : loanCap!,
                KEY_ASSESSMENT : assessment!.toJson()!,
                KEY_AMORTIZATIONS : amortizationArray,
                KEY_FREQUENCIES : frequencyArray
            ]
        }
        return nil
    }

    func toJsonData() -> Data? {
        if let json = toJson() {
            return getJsonAsData(jsonObject: json)
        }
        return nil
    }
}
