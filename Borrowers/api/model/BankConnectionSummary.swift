//
//  BankConnectionSummary.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-29.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BankConnectionSummary: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_INSTITUTION = "institution"
    private let KEY_NAME = "name"
    private let KEY_REFERENCE = "reference"

    var institution: Int?
    var name: String?
    var reference: String?

    var description: String {
        return "BankConnectionSummary [ Institution : \(institution ?? 0) , Name : \(name ?? "nil") , Reference : \(reference ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    func isValid() -> Bool {
        return (institution != nil && institution! > 0 && name != nil && name!.count > 0 && reference != nil && NSUUID(uuidString: reference!) != nil)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let institution = json.object(forKey: KEY_INSTITUTION) as? NSNumber,
                let name = json.object(forKey: KEY_NAME) as? String,
                let reference = json.object(forKey: KEY_REFERENCE) as? String {

                self.institution = institution.intValue
                self.name = name
                self.reference = reference
            }
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_REFERENCE : reference!,
                KEY_INSTITUTION : institution!,
                KEY_NAME : name!
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
