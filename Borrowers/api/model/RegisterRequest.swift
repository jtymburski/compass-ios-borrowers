//
//  RegisterRequest.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-16.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class RegisterRequest: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_COUNTRY = "country"
    private let KEY_DEVICE_ID = "device_id"
    private let KEY_EMAIL = "email"
    private let KEY_NAME = "name"
    private let KEY_PASSWORD = "password"

    var country: String?
    var deviceId: String?
    var email: String?
    var name: String?
    var password: String?

    var description: String {
        return "RegisterRequest [ Country: \(country ?? "nil") , Device ID: \(deviceId ?? "nil") , Email: \(email ?? "nil") , Name: \(name ?? "nil") , Password: \(password ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(name: String, email: String, password: String, country: String, deviceId: String) {
        self.name = name
        self.email = email
        self.password = password
        self.country = country
        self.deviceId = deviceId
    }

    func isValid() -> Bool {
        return country != nil && country!.count == Country.CODE_LENGTH && deviceId != nil && NSUUID(uuidString: deviceId!) != nil && StringHelper.isValidEmail(email) && name != nil && name!.count > 0 && StringHelper.isValidPassword(password, strong: true)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let country = json.object(forKey: KEY_COUNTRY) as? String,
                let deviceId = json.object(forKey: KEY_DEVICE_ID) as? String,
                let email = json.object(forKey: KEY_EMAIL) as? String,
                let name = json.object(forKey: KEY_NAME) as? String,
                let password = json.object(forKey: KEY_PASSWORD) as? String {

                self.country = country
                self.deviceId = deviceId
                self.email = email
                self.name = name
                self.password = password
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_NAME : name!,
                KEY_EMAIL : email!,
                KEY_PASSWORD : password!,
                KEY_COUNTRY : country!,
                KEY_DEVICE_ID : deviceId!
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
