//
//  AuthRequest.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class AuthRequest: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_DEVICE_ID = "device_id"
    private let KEY_EMAIL = "email"
    private let KEY_PASSWORD = "password"
    
    var deviceId: String?
    var email: String?
    var password: String?

    var description: String {
        return "AuthRequest [ Email : \(email ?? "nil") , Password : \(password ?? "nil") , Device ID : \(deviceId ?? "nil") ]"
    }
    
    init(_ data: Data) {
        super.init()
        parse(data)
    }
    
    init(email: String, password: String, deviceId: String) {
        self.email = email
        self.password = password
        self.deviceId = deviceId
    }

    func isValid() -> Bool {
        return (deviceId != nil && NSUUID(uuidString: deviceId!) != nil && StringHelper.isValidEmail(email) && StringHelper.isValidPassword(password))
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let deviceId = json.object(forKey: KEY_DEVICE_ID) as? String,
                let email = json.object(forKey: KEY_EMAIL) as? String,
                let password = json.object(forKey: KEY_PASSWORD) as? String {

                self.deviceId = deviceId
                self.email = email
                self.password = password
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_EMAIL : email!,
                KEY_PASSWORD : password!,
                KEY_DEVICE_ID : deviceId!
            ]
        }
        return nil
    }

    func toJsonData() -> Data? {
        if let json = toJson() {
            return getJsonAsData(jsonObject: json)
        }
        return nil
    }
}
