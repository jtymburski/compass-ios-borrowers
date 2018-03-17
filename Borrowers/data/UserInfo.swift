//
//  UserInfo.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class UserInfo {
    var countryCode: String?
    var email: String!
    var name: String?

    init(name: String, email: String, countryCode: String) {
        self.name = name
        self.email = email
        self.countryCode = countryCode
    }
}
