//
//  LoanFrequency.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-05-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanFrequency: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_DAYS = "days"
    private let KEY_ID = "id"
    private let KEY_NAME = "name"
    private let KEY_PER_MONTH = "per_month"

    var days: Int?
    var id: Int?
    var name: String?
    var perMonth: Int?

    var description: String {
        return "LoanFrequency [ ID : \(id ?? -1) , Name : \(name ?? "nil") , Days : \(days ?? -1) , Per Month : \(perMonth ?? -1) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    func getPeriodsPerYear(daysPerYear: Float, monthsPerYear: Float) -> Float {
        if days != nil && days! > 0 {
            return daysPerYear / Float(days!)
        } else if perMonth != nil && perMonth! > 0 {
            return monthsPerYear * Float(perMonth!)
        }
        return 0.0
    }

    func isValid() -> Bool {
        return id != nil && id! > 0 && name != nil && name!.count > 0 && ((days != nil && days! > 0) || (perMonth != nil && perMonth! > 0))
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let id = json.object(forKey: KEY_ID) as? Int,
            let name = json.object(forKey: KEY_NAME) as? String {

            // Core
            self.id = id
            self.name = name

            // Selective properties
            if let days = json.object(forKey: KEY_DAYS) as? Int {
                self.days = days
            }
            if let perMonth = json.object(forKey: KEY_PER_MONTH) as? Int {
                self.perMonth = perMonth
            }
        }
    }

    static func parseArray(_ data: Data) -> [LoanFrequency] {
        return parseArray(BaseModel.getJsonAsArray(with: data))
    }

    static func parseArray(_ arrayData: NSArray?) -> [LoanFrequency] {
        var loanFrequencies = [LoanFrequency]()

        if arrayData != nil {
            for object in arrayData! {
                if let json = object as? NSDictionary {
                    loanFrequencies.append(LoanFrequency.init(json))
                }
            }
        }

        return loanFrequencies
    }

    func toJson() -> Any? {
        if isValid() {
            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_ID : id!,
                KEY_NAME : name!
            ])

            if days != nil && days! > 0 {
                jsonData.addEntries(from: [ KEY_DAYS : days! ])
            }
            if perMonth != nil && perMonth! > 0 {
                jsonData.addEntries(from: [ KEY_PER_MONTH : perMonth! ])
            }
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
