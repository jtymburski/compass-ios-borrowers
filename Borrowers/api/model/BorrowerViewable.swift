//
//  BorrowerViewable.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-17.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BorrowerViewable: BorrowerEditable {
    private let KEY_ASSESSMENTS = "assessments"
    private let KEY_BANKS = "banks"
    private let KEY_COUNTRY = "country"
    private let KEY_EMAIL = "email"
    private let KEY_LOAN_CAP = "loan_cap"

    var country: String?
    var email: String?
    var loanCap: Float?

    // Read only
    var assessments: [AssessmentSummary]?
    var bankConnections: [BankConnectionSummary]?

    override var description: String {
        return "BorrowerViewable [ Address 1 : \(address1 ?? "nil") , Address 2 : \(address2 ?? "nil") , Address 3 : \(address3 ?? "nil") , City : \(city ?? "nil") , Country : \(country ?? "nil") , Email : \(email ?? "nil") , Employer : \(employer ?? "nil") , Job Title : \(jobTitle ?? "nil") , Loan Cap : \(loanCap ?? 0.0) , Name : \(name ?? "nil") , Phone : \(phone ?? "nil") , Post Code : \(postCode ?? "nil") , Province : \(province ?? "nil") ]"
    }

    override init(_ data: Data) {
        super.init(data)
    }

    override func isValid() -> Bool {
        return isValid(minStringSize: 0)
    }

    override func isValid(minStringSize: Int) -> Bool {
        return super.isValid(minStringSize: minStringSize) && country != nil && country!.count == Country.CODE_LENGTH && StringHelper.isValidEmail(email)
    }

    override func parse(json: NSDictionary) -> Bool {
        if let email = json.object(forKey: KEY_EMAIL) as? String,
            let country = json.object(forKey: KEY_COUNTRY) as? String {
            if super.parse(json: json) {

                // Required
                self.email = email
                self.country = country

                // Optional
                self.loanCap = (json.object(forKey: KEY_LOAN_CAP) as? NSNumber)?.floatValue

                // Assessments (optional)
                if let assessments = json.object(forKey: KEY_ASSESSMENTS) as? NSArray {
                    self.assessments = []
                    for a in assessments {
                        if let json = a as? NSDictionary {
                            self.assessments!.append(AssessmentSummary.init(json))
                        }
                    }
                }

                // Bank connections (optional)
                if let bankConnections = json.object(forKey: KEY_BANKS) as? NSArray {
                    self.bankConnections = []
                    for bc in bankConnections {
                        if let json = bc as? NSDictionary {
                            self.bankConnections!.append(BankConnectionSummary.init(json))
                        }
                    }
                }

                return true
            }
        }
        return false
    }

    override func toJson() -> Any? {
        if var parentDict = super.toJson() as? Dictionary<String, Any> {
            parentDict[KEY_EMAIL] = email!
            parentDict[KEY_COUNTRY] = country!
            parentDict[KEY_LOAN_CAP] = loanCap!

            return parentDict
        }
        return nil
    }
}
