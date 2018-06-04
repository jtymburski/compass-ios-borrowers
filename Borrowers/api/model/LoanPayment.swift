//
//  LoanPayment.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-03.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanPayment: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_AMOUNT = "amount"
    private let KEY_INTEREST = "interest"
    private let KEY_DUE_DATE = "due_date"
    private let KEY_PAID_DATE = "paid_date"

    var amount: Float?
    var dueDate: Int64?
    var interest: Float?
    var paidDate: Int64?

    var description: String {
        return "LoanPayment [ Amount : \(amount ?? 0.0) , Interest : \(interest ?? 0.0) , Due Date : \(dueDate ?? 0) , Paid Date : \(paidDate ?? 0) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    func isValid() -> Bool {
        return (amount != nil && amount! > 0.0 && interest != nil && interest! > 0 && dueDate != nil && dueDate! > 0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let amountNum = json.object(forKey: KEY_AMOUNT) as? NSNumber,
            let interestNum = json.object(forKey: KEY_INTEREST) as? NSNumber,
            let dueDateNum = json.object(forKey: KEY_DUE_DATE) as? NSNumber {

            // Required
            self.amount = amountNum.floatValue
            self.interest = interestNum.floatValue
            self.dueDate = dueDateNum.int64Value

            // Optional
            self.paidDate =  (json.object(forKey: KEY_PAID_DATE) as? NSNumber)?.int64Value
        }
    }

    static func parseArray(_ data: Data) -> [LoanPayment] {
        return parseArray(BaseModel.getJsonAsArray(with: data))
    }

    static func parseArray(_ arrayData: NSArray?) -> [LoanPayment] {
        var loanPayments = [LoanPayment]()

        if arrayData != nil {
            for object in arrayData! {
                if let json = object as? NSDictionary {
                    loanPayments.append(LoanPayment.init(json))
                }
            }
        }

        return loanPayments
    }

    func toJson() -> Any? {
        if isValid() {
            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_AMOUNT : amount!,
                KEY_INTEREST : interest!,
                KEY_DUE_DATE : dueDate!
            ])
            if paidDate != nil {
                jsonData.addEntries(from: [ KEY_PAID_DATE : paidDate! ])
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
