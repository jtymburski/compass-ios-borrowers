//
//  BankConnectionNew.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-29.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BankConnectionNew: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_ACCOUNT = "account"
    private let KEY_BANK_ID = "bank_id"
    private let KEY_LOGIN_ID = "login_id"
    private let KEY_TRANSIT = "transit"

    var account: Int?
    var bankId: Int?
    var loginId: String?
    var transit: Int?

    var description: String {
        return "BankConnectionNew [ Account : \(account ?? 0) , Bank ID : \(bankId ?? 0) , Login ID : \(loginId ?? "nil") , Transit : \(transit ?? 0) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(bankId: Int?, transit: Int?, account: Int?, loginId: String?) {
        super.init()
        self.bankId = bankId
        self.transit = transit
        self.account = account
        self.loginId = loginId
    }

    func isValid() -> Bool {
        return (account != nil && account! > 0 && bankId != nil && bankId! > 0 && loginId != nil && NSUUID(uuidString: loginId!) != nil && transit != nil && transit! > 0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let account = json.object(forKey: KEY_ACCOUNT) as? NSNumber,
                let bankId = json.object(forKey: KEY_BANK_ID) as? NSNumber,
                let loginId = json.object(forKey: KEY_LOGIN_ID) as? String,
                let transit = json.object(forKey: KEY_TRANSIT) as? NSNumber {

                self.account = account.intValue
                self.bankId = bankId.intValue
                self.loginId = loginId
                self.transit = transit.intValue
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_LOGIN_ID : loginId!,
                KEY_BANK_ID : bankId!,
                KEY_TRANSIT : transit!,
                KEY_ACCOUNT : account!
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
