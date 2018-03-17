//
//  CoreModelController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class CoreModelController {
    var account: Account!
    var supportedCountries: [Country]?
    var userInfo: UserInfo?

    init() {
        account = Account.getOrCreate()
    }

    func authenticate(_ response: AuthResponse) {
        account.sessionKey = response.sessionKey
        account.userKey = response.userKey
    }

    func clear() {
        account.clear()
        userInfo = nil
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
    }
}
