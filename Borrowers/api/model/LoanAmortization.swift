//
//  LoanAmortization.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanAmortization: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_ID = "id"
    private let KEY_MONTHS = "months"
    private let KEY_NAME = "name"

    var id: Int?
    var months: Int?
    var name: String?

    var description: String {
        return "LoanAmortization [ ID : \(id ?? -1) , Name : \(name ?? "nil") , Months : \(months ?? -1) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    func getTotalYears(monthsPerYear: Float) -> Float {
        if months != nil && months! > 0 {
            return Float(months!) / monthsPerYear
        }
        return 0.0
    }

    func isValid() -> Bool {
        return id != nil && id! > 0 && months != nil && months! > 0 && name != nil && name!.count > 0
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let id = json.object(forKey: KEY_ID) as? Int,
            let months = json.object(forKey: KEY_MONTHS) as? Int,
            let name = json.object(forKey: KEY_NAME) as? String {

            self.id = id
            self.months = months
            self.name = name
        }
    }

    static func parseArray(_ data: Data) -> [LoanAmortization] {
        return parseArray(BaseModel.getJsonAsArray(with: data))
    }

    static func parseArray(_ arrayData: NSArray?) -> [LoanAmortization] {
        var loanAmortizations = [LoanAmortization]()

        if arrayData != nil {
            for object in arrayData! {
                if let json = object as? NSDictionary {
                    loanAmortizations.append(LoanAmortization.init(json))
                }
            }
        }

        return loanAmortizations
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_ID : id!,
                KEY_NAME : name!,
                KEY_MONTHS : months!
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
