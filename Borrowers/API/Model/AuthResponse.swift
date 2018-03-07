//
//  AuthResponse.swift
//  Borrowers
//
//  Created by Kevin Smith on 2018-03-07.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class AuthResponse: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_SESSION = "session_key"
    private let KEY_USER = "user_key"
    
    var sessionKey: String?
    var userKey: String?

    var description: String {
        return "AuthResponse [ Session : \(sessionKey ?? "nil") , User: \(userKey ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    func isValid() -> Bool {
        return (sessionKey != nil && sessionKey!.count > 0 && userKey != nil && userKey!.count > 0)
    }
    
    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let sessionKey = json.object(forKey: KEY_SESSION) as? String,
                    let userKey = json.object(forKey: KEY_USER) as? String {
                self.sessionKey = sessionKey
                self.userKey = userKey
            }
        }
    }
}
