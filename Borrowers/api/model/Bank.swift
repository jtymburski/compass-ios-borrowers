//
//  Bank.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-29.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class Bank: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_CODE = "code"
    private let KEY_ID = "id"
    private let KEY_NAME = "name"

    var code: Int?
    var id: Int?
    var name: String?

    var description: String {
        return "Bank [ ID : \(id ?? 0) , Code : \(code ?? 0) , Name : \(name ?? "nil") ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    func isValid() -> Bool {
        return code != nil && code! > 0 && id != nil && id! > 0 && name != nil && name!.count > 0
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let code = json.object(forKey: KEY_CODE) as? NSNumber,
            let id = json.object(forKey: KEY_ID) as? NSNumber,
            let name = json.object(forKey: KEY_NAME) as? String {

            self.code = code.intValue
            self.id = id.intValue
            self.name = name
        }
    }

    static func parseArray(_ data: Data) -> [Bank] {
        var banks = [Bank]()

        if let arrayData = BaseModel.getJsonAsArray(with: data) {
            for object in arrayData {
                if let json = object as? NSDictionary {
                    banks.append(Bank.init(json))
                }
            }
        }

        return banks
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_ID : id!,
                KEY_CODE : code!,
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
