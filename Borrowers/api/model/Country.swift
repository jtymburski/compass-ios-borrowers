//
//  Country.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-12.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class Country: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let CODE_LENGTH = 2
    private let KEY_CODE = "code"
    private let KEY_NAME = "name"

    var code: String?
    var name: String?

    var description: String {
        return "Country [ Code : \(code ?? "nil") , Name : \(name ?? "nil") ]"
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
        return code != nil && code!.count == CODE_LENGTH && name != nil && name!.count > 0
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let code = json.object(forKey: KEY_CODE) as? String,
            let name = json.object(forKey: KEY_NAME) as? String {
            self.code = code
            self.name = name
        }
    }

    static func parseArray(_ data: Data) -> [Country] {
        var countries = [Country]()

        if let arrayData = BaseModel.getJsonAsArray(with: data) {
            for object in arrayData {
                if let json = object as? NSDictionary {
                    countries.append(Country.init(json))
                }
            }
        }

        return countries
    }

    func toJson() -> Any? {
        if isValid() {
            return [
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
