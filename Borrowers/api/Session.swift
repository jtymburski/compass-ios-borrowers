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
