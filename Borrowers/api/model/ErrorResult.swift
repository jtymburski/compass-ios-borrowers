//
//  ErrorResult.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-07.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class ErrorResult: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_ERROR_CODE = "error_code"
    private let KEY_ERROR_STRING = "error_string"

    var errorCode: Int?
    var errorString: String?
    
    var description: String {
        return "ErrorResult [ Code : \(errorCode ?? -1) , String: \(errorString ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }
    
    func isValid() -> Bool {
        return errorCode != nil && errorString != nil && errorString!.count > 0
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let errorCode = json.object(forKey: KEY_ERROR_CODE) as? Int,
                    let errorString = json.object(forKey: KEY_ERROR_STRING) as? String {
                self.errorCode = errorCode
                self.errorString = errorString
            }
        }
    }
    
    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_ERROR_CODE : errorCode!,
                KEY_ERROR_STRING : errorString!
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
