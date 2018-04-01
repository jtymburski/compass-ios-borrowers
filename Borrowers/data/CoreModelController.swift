//
//  CoreModelController.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation
import UIKit

class CoreModelController {
    // Borrower
    var account: Account!
    var activeAssessment: AssessmentInfo?
    var bankConnections: [BankConnectionSummary]?
    var userInfo: UserInfo?
    var verificationFiles: [VerificationFile] = []

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

    func getVerificationFile(index: Int) -> VerificationFile {
        return verificationFiles[index]
    }

    func hasBankConnections() -> Bool {
        return bankConnections != nil && bankConnections!.count > 0
    }

    func hasReadyAssessment() -> Bool {
        return activeAssessment != nil && activeAssessment!.isValid() && activeAssessment!.hasUploadedFiles()
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

    func isVerificationFileValid(index: Int) -> Bool {
        if index >= 0 && index < verificationFiles.count {
            return verificationFiles[index].isValid()
        }
        return false
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

    func setVerificationFile(index: Int, image: UIImage, name: String) {
        while verificationFiles.count <= index {
            verificationFiles.append(VerificationFile.init())
        }
        verificationFiles[index].set(image: image, name: name)
    }
}
