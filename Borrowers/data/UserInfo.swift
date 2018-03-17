//
//  UserInfo.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class UserInfo {
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var countryCode: String?
    var email: String!
    var employer: String?
    var jobTitle: String?
    var loanCap: Float?
    var name: String?
    var phone: String?
    var postCode: String?
    var province: String?

    init(from info: BorrowerViewable) {
        update(from: info)
    }

    init(name: String, email: String, countryCode: String) {
        self.name = name
        self.email = email
        self.countryCode = countryCode
    }

    func hasValidDetails() -> Bool {
        return address1 != nil && address1!.count > 0 && city != nil && city!.count > 0 && employer != nil && employer!.count > 0 && jobTitle != nil && jobTitle!.count > 0 && phone != nil && phone!.count > 0
    }

    func update(from info: BorrowerViewable) {
        address1 = info.address1
        address2 = info.address2
        address3 = info.address3
        city = info.city
        countryCode = info.country
        email = info.email
        employer = info.employer
        jobTitle = info.jobTitle
        loanCap = info.loanCap
        name = info.name
        phone = info.phone
        postCode = info.postCode
        province = info.province
    }
}
