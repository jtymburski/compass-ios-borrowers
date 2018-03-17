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

    func isLoggedIn() -> Bool {
        return account.isLoggedIn()
    }
}
