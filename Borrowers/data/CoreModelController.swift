//
//  CoreModelController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class CoreModelController {
    // Borrower
    var account: Account!
    var bankConnections: [BankConnectionSummary]?
    var userInfo: UserInfo?

    // Info
    var supportedCountries: [Country]?
    var supportedBanks: [Bank]?

    init() {
        account = Account.getOrCreate()
    }

    func addBankSummary(_ summary: BankConnectionSummary) {
        if(bankConnections == nil) {
            bankConnections = [summary]
        } else {
            bankConnections!.append(summary)
        }
    }

    func authenticate(_ response: AuthResponse) {
        account.sessionKey = response.sessionKey
        account.userKey = response.userKey
    }

    func clear() {
        account.clear()
        userInfo = nil
    }

    func hasBankConnections() -> Bool {
        return bankConnections != nil && bankConnections!.count > 0
    }

    func hasValidDetails() -> Bool {
        if userInfo != nil {
            return userInfo!.hasValidDetails()
        }
        return false
    }

    func isLoggedIn() -> Bool {
        return account.isLoggedIn()
    }

    func updateUserInfo(from info: BorrowerViewable) {
        if userInfo != nil {
            userInfo?.update(from: info)
        } else {
            userInfo = UserInfo.init(from: info)
        }

        if(info.bankConnections != nil) {
            bankConnections = info.bankConnections
        }
    }
}
