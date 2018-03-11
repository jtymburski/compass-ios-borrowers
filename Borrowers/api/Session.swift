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
    static let baseUrl = "https://first-project-196541.appspot.com/core/v1/"

    // MARK: - Functions

    static func borrowerLogin(input: AuthRequest, completionHandler: @escaping (AuthResponse?, String?, Bool) -> Void) {
        let function = "borrowers/login"
        let method = "POST"

        startRequest(function: function, method: method, body: input.toJsonData()) { (data, response, error) in
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

    // MARK: - Internals

    static func startRequest(function: String, method: String, body: Data?, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: URL(string: baseUrl + function)!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if(body != nil) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }

        URLSession.shared.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
