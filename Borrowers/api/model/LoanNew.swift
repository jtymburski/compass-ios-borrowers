//
//  LoanNew.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-03.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanNew: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_AMORTIZATION = "amortization"
    private let KEY_BANK = "bank"
    private let KEY_FREQUENCY = "frequency"
    private let KEY_PRINCIPAL = "principal"

    var amortization: Int?
    var bank: String?
    var frequency: Int?
    var principal: Int?

    var description: String {
        return "LoanNew [ Bank : \(bank ?? "nil") , Principal : \(principal ?? 0) , Amortization ID : \(amortization ?? 0) , Frequency ID : \(frequency ?? 0) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(bank: String?, principal: Int?, amortization: Int?, frequency: Int?) {
        self.amortization = amortization
        self.bank = bank
        self.frequency = frequency
        self.principal = principal
    }

    func isValid() -> Bool {
        return (amortization != nil && amortization! > 0 && bank != nil && NSUUID(uuidString: bank!) != nil && frequency != nil && frequency! > 0 && principal != nil && principal! > 0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let amortization = json.object(forKey: KEY_AMORTIZATION) as? NSNumber,
                let bank = json.object(forKey: KEY_BANK) as? String,
                let frequency = json.object(forKey: KEY_FREQUENCY) as? NSNumber,
                let principal = json.object(forKey: KEY_PRINCIPAL) as? NSNumber {

                self.amortization = amortization.intValue
                self.bank = bank
                self.frequency = frequency.intValue
                self.principal = principal.intValue
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_BANK : bank!,
                KEY_PRINCIPAL : principal!,
                KEY_AMORTIZATION : amortization!,
                KEY_FREQUENCY : frequency!
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
