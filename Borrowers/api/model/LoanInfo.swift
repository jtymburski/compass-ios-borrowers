//
//  LoanInfo.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-03.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class LoanInfo: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_AMORTIZATION = "amortization"
    private let KEY_BALANCE = "balance"
    private let KEY_BANK = "bank"
    private let KEY_CREATED = "created"
    private let KEY_FREQUENCY = "frequency"
    private let KEY_NEXT_PAYMENT = "next_payment"
    private let KEY_PAYMENTS = "payments"
    private let KEY_PRINCIPAL = "principal"
    private let KEY_RATE = "rate"
    private let KEY_RATING = "rating"
    private let KEY_REFERENCE = "reference"
    private let KEY_STARTED = "started"

    var amortization: LoanAmortization?
    var balance: Float?
    var bank: BankConnectionSummary?
    var created: Int64?
    var frequency: LoanFrequency?
    var nextPayment: LoanPayment?
    var payments: [LoanPayment]?
    var principal: Int?
    var rate: Float?
    var rating: Int?
    var reference: String?
    var started: Int64?

    var description: String {
        return "LoanInfo [ Reference : \(reference ?? "nil") , Created : \(created ?? 0) , Bank : \(bank?.description ?? "nil") , Principal : \(principal ?? 0) , Rating : \(rating ?? 0) , Rate : \(rate ?? 0.0) , Amortization : \(amortization?.description ?? "nil") , Frequency : \(frequency?.description ?? "nil") , Started : \(started ?? 0) , Balance : \(balance ?? 0.0) , Payments : \(payments?.count ?? 0) , Next Payment : \(nextPayment?.description ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }


    func isValid() -> Bool {
        return (reference != nil && NSUUID(uuidString: reference!) != nil && created != nil && created! > 0 && bank != nil && bank!.isValid() && principal != nil && principal! > 0 && rating != nil && rating! > 0 && rate != nil && rate! > 0.0 && amortization != nil && amortization!.isValid() && frequency != nil && frequency!.isValid())
    }


    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let reference = json.object(forKey: KEY_REFERENCE) as? String,
                let createdNum = json.object(forKey: KEY_CREATED) as? NSNumber,
                let bankJson = json.object(forKey: KEY_BANK) as? NSDictionary,
                let principal = json.object(forKey: KEY_PRINCIPAL) as? Int,
                let rating = json.object(forKey: KEY_RATING) as? Int,
                let rate = json.object(forKey: KEY_RATE) as? Float,
                let amortizationJson = json.object(forKey: KEY_AMORTIZATION) as? NSDictionary,
                let frequencyJson = json.object(forKey: KEY_FREQUENCY) as? NSDictionary {

                // Required
                self.reference = reference
                self.created = createdNum.int64Value
                self.bank = BankConnectionSummary(bankJson)
                self.principal = principal
                self.rating = rating
                self.rate = rate
                self.amortization = LoanAmortization(amortizationJson)
                self.frequency = LoanFrequency(frequencyJson)

                // Optional
                self.started = (json.object(forKey: KEY_STARTED) as? NSNumber)?.int64Value
                self.balance = (json.object(forKey: KEY_BALANCE) as? Float)
                if let paymentArray = json.object(forKey: KEY_PAYMENTS) as? NSArray {
                    self.payments = LoanPayment.parseArray(paymentArray)
                }
                if let nextPaymentJson = json.object(forKey: KEY_NEXT_PAYMENT) as? NSDictionary {
                    self.nextPayment = LoanPayment(nextPaymentJson)
                }
            }
        }
    }

    // TODO: BELOW

    func toJson() -> Any? {
        if isValid() {
            // Required
            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_REFERENCE : reference!,
                KEY_CREATED : created!,
                KEY_BANK : bank!.toJson()!,
                KEY_PRINCIPAL : principal!,
                KEY_RATING : rating!,
                KEY_RATE : rate!,
                KEY_AMORTIZATION : amortization!.toJson()!,
                KEY_FREQUENCY : frequency!.toJson()!
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

            // Optional payments array
            if payments != nil && payments!.count > 0 {
                let paymentsArray = NSMutableArray.init()
                for payment in payments! {
                    if payment.isValid() {
                        paymentsArray.add(payment.toJson()!)
                    }
                }
                if paymentsArray.count > 0 {
                    jsonData.addEntries(from: [ KEY_PAYMENTS : paymentsArray ])
                }
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
