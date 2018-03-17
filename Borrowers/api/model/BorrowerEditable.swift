//
//  BorrowerEditable.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-17.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BorrowerEditable: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_ADDRESS1 = "address1"
    private let KEY_ADDRESS2 = "address2"
    private let KEY_ADDRESS3 = "address3"
    private let KEY_CITY = "city"
    private let KEY_EMPLOYER = "employer"
    private let KEY_JOB_TITLE = "job_title"
    private let KEY_NAME = "name"
    private let KEY_PHONE = "phone"
    private let KEY_POST_CODE = "post_code"
    private let KEY_PROVINCE = "province"

    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var employer: String?
    var jobTitle: String?
    var name: String?
    var phone: String?
    var postCode: String?
    var province: String?

    var description: String {
        return "BorrowerEditable [ Address 1 : \(address1 ?? "nil") , Address 2 : \(address2 ?? "nil") , Address 3 : \(address3 ?? "nil") , City : \(city ?? "nil") , Employer : \(employer ?? "nil") , Job Title : \(jobTitle ?? "nil") , Name : \(name ?? "nil") , Phone : \(phone ?? "nil") , Post Code : \(postCode ?? "nil") , Province : \(province ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(name: String, address1: String, city: String, phone: String, employer: String, jobTitle: String) {
        self.name = name
        self.address1 = address1
        self.city = city
        self.phone = phone
        self.employer = employer
        self.jobTitle = jobTitle
    }

    func isValid() -> Bool {
        return isValid(minStringSize: 1)
    }

    func isValid(minStringSize: Int) -> Bool {
        return name != nil && name!.count >= minStringSize && address1 != nil && address1!.count >= minStringSize && city != nil && city!.count >= minStringSize && phone != nil && phone!.count >= minStringSize && employer != nil && employer!.count >= minStringSize && jobTitle != nil && jobTitle!.count >= minStringSize
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            _ = parse(json: json)
        }
    }

    func parse(json: NSDictionary) -> Bool {
        if let name = json.object(forKey: KEY_NAME) as? String,
            let address1 = json.object(forKey: KEY_ADDRESS1) as? String,
            let city = json.object(forKey: KEY_CITY) as? String,
            let phone = json.object(forKey: KEY_PHONE) as? String,
            let employer = json.object(forKey: KEY_EMPLOYER) as? String,
            let jobTitle = json.object(forKey: KEY_JOB_TITLE) as? String {

            // Required
            self.name = name
            self.address1 = address1
            self.city = city
            self.phone = phone
            self.employer = employer
            self.jobTitle = jobTitle

            // Optional
            self.address2 = json.object(forKey: KEY_ADDRESS2) as? String
            self.address3 = json.object(forKey: KEY_ADDRESS3) as? String
            self.postCode = json.object(forKey: KEY_POST_CODE) as? String
            self.province = json.object(forKey: KEY_PROVINCE) as? String

            return true
        }
        return false
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_NAME: name!,
                KEY_ADDRESS1: address1!,
                KEY_ADDRESS2: address2,
                KEY_ADDRESS3: address3,
                KEY_CITY: city!,
                KEY_PROVINCE: province,
                KEY_POST_CODE: postCode,
                KEY_PHONE: phone!,
                KEY_EMPLOYER: employer!,
                KEY_JOB_TITLE: jobTitle!
            ]
        }
        return nil
    }

    func toJsonData() -> Data? {
        if let json = toJson() {
            return getJsonAsData(jsonObject:json)
        }
        return nil
    }
}
