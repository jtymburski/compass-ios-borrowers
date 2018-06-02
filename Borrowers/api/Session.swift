//
//  Session.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation
import HTTPStatusCodes

struct Session {
    // Dev
    static let host = "https://first-project-196541.appspot.com"
    static let baseUrl = host + "/core/v1/"

    // MARK: - Functions

    static func assessmentCreate(account: Account, completionHandler: @escaping (AssessmentInfo?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey! + "/assessments"
        let method = "POST"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var assessmentInfo: AssessmentInfo?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.created {
                    assessmentInfo = AssessmentInfo.init(data, reference: nil)
                    if !assessmentInfo!.isValid() {
                        errorString = "The server received invalid response for the assessment create request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the assessment create request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on assessment create attempt: \(error!)")
                }
            }

            completionHandler(assessmentInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func assessmentInfo(account: Account, assessment: AssessmentSummary, completionHandler: @escaping (AssessmentInfo?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey! + "/assessments/" + assessment.reference!
        let method = "GET"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var assessmentInfo: AssessmentInfo?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    assessmentInfo = AssessmentInfo.init(data, reference: assessment.reference)
                    if !assessmentInfo!.isValid() {
                        errorString = "The server received invalid response for the assessment info fetch request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the assessment info fetch request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on assessment info fetch attempt: \(error!)")
                }
            }

            completionHandler(assessmentInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func assessmentSubmit(account: Account, assessment: AssessmentInfo, completionHandler: @escaping (Bool, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey! + "/assessments/" + assessment.reference!
        let method = "POST"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var success = false
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    success = true
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    if data != nil {
                        let errorResult = ErrorResult.init(data!)
                        if errorResult.isValid() {
                            print(errorResult)
                        }
                    }
                    errorString = "The server failed to submit the assessment request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on assessment submit request attempt: \(error!)")
                }
            }

            completionHandler(success, errorString, noNetwork, unauthorized)
        }
    }

    static func assessmentUpload(urlString: String, files: [VerificationFile], completionHandler: @escaping (Bool, String?, Bool) -> Void) -> Bool {
        // Create the URL
        if let url = URL(string: urlString) {
            // Build the custom form upload request header
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            // Form upload body
            let body = NSMutableData()
            let boundaryPrefix = "--\(boundary)\r\n"
            var fileIndex = 1
            for file in files {
                if file.isValid() {
                    body.appendString(boundaryPrefix)
                    body.appendString("Content-Disposition: form-data; name=\"\(fileIndex)\"; filename=\"\(file.name!)\"\r\n")
                    body.appendString("Content-Type: \(file.getContentType())\r\n\r\n")
                    body.append(file.getData()!)
                    body.appendString("\r\n")

                    fileIndex += 1
                }
            }
            body.appendString(boundaryPrefix.appending("--"))
            if fileIndex > 1 {
                // Start the session request
                URLSession.shared.uploadTask(with: request, from: body as Data, completionHandler: { (data, response, error) in
                    var errorString: String?
                    var noNetwork = false
                    var success = false

                    // Determine if the result is valid
                    if let response = response as? HTTPURLResponse {
                        // Check the HTTP result
                        if response.statusCodeEnum == HTTPStatusCode.ok {
                            success = true
                        } else {
                            errorString = "The server failed to process the assessment upload request with status: \(response.statusCode)"
                        }
                    } else {
                        noNetwork = true
                        if error != nil {
                            print("General failure on assessment upload attempt: \(error!)")
                        }
                    }

                    completionHandler(success, errorString, noNetwork)
                }).resume()

                return true
            }
        }

        return false
    }

    static func bankCreate(account: Account, input: BankConnectionNew, completionHandler: @escaping (BankConnectionSummary?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey! + "/banks"
        let method = "POST"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: input.toJsonData()) { (data, response, error) in
            var bankInfo: BankConnectionSummary?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.created {
                    bankInfo = BankConnectionSummary.init(data)
                    if !bankInfo!.isValid() {
                        errorString = "The server received invalid response for the bank create request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the bank create request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on bank create attempt: \(error!)")
                }
            }

            completionHandler(bankInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func banks(userInfo: UserInfo!, completionHandler: @escaping ([Bank]?, String?, Bool) -> Void) {
        let function = "countries/" + userInfo.countryCode! + "/banks"
        let method = "GET"

        startRequest(function: function, method: method, accessKey: nil, body: nil) { (data, response, error) in
            var banks: [Bank]?
            var errorString: String?
            var noNetwork = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    banks = Bank.parseArray(data, sort: true)
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the bank list fetch request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on bank list fetch: \(error!)")
                }
            }

            completionHandler(banks, errorString, noNetwork)
        }
    }

    static func borrowerCreate(input: RegisterRequest, completionHandler: @escaping (AuthResponse?, String?, Bool, Bool) -> Void) {
        let function = "borrowers"
        let method = "POST"

        startRequest(function: function, method: method, accessKey: nil, body: input.toJsonData()) { (data, response, error) in
            var authResponse: AuthResponse?
            var emailExists = false
            var errorString: String?
            var noNetwork = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.created {
                    authResponse = AuthResponse.init(data)
                    if !authResponse!.isValid() {
                        errorString = "The server received invalid response for the create request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.conflict {
                    errorString = "The email is already tied to an existing account"
                    emailExists = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the create request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on create attempt: \(error!)")
                }
            }

            completionHandler(authResponse, errorString, noNetwork, emailExists)
        }
    }

    static func borrowerInfo(account: Account, completionHandler: @escaping (BorrowerViewable?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey!
        let method = "GET"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var borrowerInfo: BorrowerViewable?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    borrowerInfo = BorrowerViewable.init(data)
                    if !borrowerInfo!.isValid() {
                        errorString = "The server received invalid response for the borrower info fetch request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the borrower info fetch request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on borrower info fetch attempt: \(error!)")
                }
            }

            completionHandler(borrowerInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func borrowerLogin(input: AuthRequest, completionHandler: @escaping (AuthResponse?, String?, Bool) -> Void) {
        let function = "borrowers/login"
        let method = "POST"

        startRequest(function: function, method: method, accessKey: nil, body: input.toJsonData()) { (data, response, error) in
            var authResponse: AuthResponse?
            var errorString: String?
            var noNetwork = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    authResponse = AuthResponse.init(data)
                    if !authResponse!.isValid() {
                        errorString = "The server received invalid response for the log in request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    errorString = "The username or password is invalid"
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the log in request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on login attempt: \(error!)")
                }
            }

            completionHandler(authResponse, errorString, noNetwork)
        }
    }

    static func borrowerUpdate(account: Account, input: BorrowerEditable, completionHandler: @escaping (BorrowerViewable?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey!
        let method = "PUT"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: input.toJsonData()) { (data, response, error) in
            var borrowerInfo: BorrowerViewable?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    borrowerInfo = BorrowerViewable.init(data)
                    if !borrowerInfo!.isValid() {
                        errorString = "The server received invalid response for the borrower info update request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the borrower info update request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on borrower info update attempt: \(error!)")
                }
            }

            completionHandler(borrowerInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func countries(completionHandler: @escaping ([Country]?, String?, Bool) -> Void) {
        let function = "countries"
        let method = "GET"

        startRequest(function: function, method: method, accessKey: nil, body: nil) { (data, response, error) in
            var countries: [Country]?
            var errorString: String?
            var noNetwork = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    countries = Country.parseArray(data)
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the country list fetch request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on country list fetch: \(error!)")
                }
            }

            completionHandler(countries, errorString, noNetwork)
        }
    }

    static func loanAvailable(account: Account, completionHandler: @escaping (LoanAvailable?, String?, Bool, Bool) -> Void) {
        let function = "borrowers/" + account.userKey! + "/loans/available"
        let method = "GET"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var loanAvailableInfo: LoanAvailable?
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse, let data = data {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    loanAvailableInfo = LoanAvailable.init(data)
                    if !loanAvailableInfo!.isValid() {
                        errorString = "The server received invalid response for the loan available info fetch request"
                    }
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    let errorResult = ErrorResult.init(data)
                    if errorResult.isValid() {
                        print(errorResult)
                    }
                    errorString = "The server failed to process the loan available info fetch request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on loan available info fetch attempt: \(error!)")
                }
            }

            completionHandler(loanAvailableInfo, errorString, noNetwork, unauthorized)
        }
    }

    static func logout(account: Account, completionHandler: ((_ success: Bool, _ error: String?, _ noNetwork: Bool, _ unauthorized: Bool) -> Void)?) {
        let function = "borrowers/" + account.userKey! + "/logout"
        let method = "POST"

        startRequest(function: function, method: method, accessKey: account.getAccessKey(), body: nil) { (data, response, error) in
            var success = false
            var errorString: String?
            var noNetwork = false
            var unauthorized = false

            // Determine if the result is valid
            if let response = response as? HTTPURLResponse {
                // Check the HTTP result
                if response.statusCodeEnum == HTTPStatusCode.ok {
                    success = true
                } else if response.statusCodeEnum == HTTPStatusCode.unauthorized {
                    unauthorized = true
                } else {
                    if data != nil {
                        let errorResult = ErrorResult.init(data!)
                        if errorResult.isValid() {
                            print(errorResult)
                        }
                    }
                    errorString = "The server failed to process the borrower logout request"
                }
            } else {
                noNetwork = true
                if error != nil {
                    print("General failure on borrower logout attempt: \(error!)")
                }
            }

            if completionHandler != nil {
                completionHandler!(success, errorString, noNetwork, unauthorized)
            }
        }
    }

    // MARK: - Internals

    static func startRequest(function: String, method: String, accessKey: String?, body: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: baseUrl + function)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if accessKey != nil {
            request.setValue(accessKey!, forHTTPHeaderField: "access_key")
        }
        if(body != nil) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }

        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        append(string.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
    }
}
