//
//  LoanSummary.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-04.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanSummary: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_BALANCE = "balance"
    private let KEY_NEXT_PAYMENT = "next_payment"
    private let KEY_PRINCIPAL = "principal"
    private let KEY_RATE = "rate"
    private let KEY_REFERENCE = "reference"
    private let KEY_STARTED = "started"

    var balance: Float?
    var nextPayment: LoanPayment?
    var principal: Int?
    var rate: Float?
    var reference: String?
    var started: Int64?

    var description: String {
        return "LoanSummary [ Reference : \(reference ?? "nil") , Principal : \(principal ?? 0) , Rate : \(rate ?? 0.0) , Started : \(started ?? 0) , Balance : \(balance ?? 0.0) , Next Payment : \(nextPayment?.description ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    init(reference: String?, principal: Int?, rate: Float?, started: Int64?, balance: Float?, nextPayment: LoanPayment?) {
        super.init()
        self.reference = reference
        self.principal = principal
        self.rate = rate
        self.started = started
        self.balance = balance
        self.nextPayment = nextPayment
    }

    func getRatePercent() -> NSNumber {
        if rate != nil {
            return (rate! * 100) as NSNumber
        }
        return 0
    }

    func isCompleted() -> Bool {
        return (started != nil && started! > 0 && balance != nil && balance! <= 0.0)
    }

    func isInProgress() -> Bool {
        return (started != nil && started! > 0 && balance != nil && balance! > 0.0 && nextPayment != nil && nextPayment!.isValid())
    }

    func isValid() -> Bool {
        return (reference != nil && NSUUID(uuidString: reference!) != nil && principal != nil && principal! > 0 && rate != nil && rate! > 0.0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let reference = json.object(forKey: KEY_REFERENCE) as? String,
            let principal = json.object(forKey: KEY_PRINCIPAL) as? Int,
            let rate = json.object(forKey: KEY_RATE) as? Float {

            // Required
            self.reference = reference
            self.principal = principal
            self.rate = rate

            // Optional
            self.started = (json.object(forKey: KEY_STARTED) as? NSNumber)?.int64Value
            self.balance = (json.object(forKey: KEY_BALANCE) as? Float)
            if let nextPaymentJson = json.object(forKey: KEY_NEXT_PAYMENT) as? NSDictionary {
                self.nextPayment = LoanPayment(nextPaymentJson)
            }
        }
    }

    static func parseArray(_ data: Data) -> [LoanSummary] {
        var loanList = [LoanSummary]()

        if let arrayData = BaseModel.getJsonAsArray(with: data) {
            for object in arrayData {
                if let json = object as? NSDictionary {
                    let loan = LoanSummary.init(json)
                    if loan.isValid() {
                        loanList.append(loan)
                    }
                }
            }
        }

        return loanList
    }

    func toJson() -> Any? {
        if isValid() {
            // Required
            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_REFERENCE : reference!,
                KEY_PRINCIPAL : principal!,
                KEY_RATE : rate!
            ])

            // Optional core
            if started != nil && started! > 0 {
                jsonData.addEntries(from: [ KEY_STARTED : started! ])
            }
            if balance != nil && balance! > 0.0 {
                jsonData.addEntries(from: [ KEY_BALANCE : balance! ])
            }
            if nextPayment != nil && nextPayment!.isValid() {
                jsonData.addEntries(from: [ KEY_NEXT_PAYMENT : nextPayment!.toJson()! ])
            }

            return jsonData
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
