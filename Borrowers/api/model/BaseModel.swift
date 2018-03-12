//
//  AbstractModel.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-07.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BaseModel {
    static func getJsonAsArray(with data: Data) -> NSArray? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                return json
            }
        } catch {
            print("JSON response parsing array failure: \(error)")
        }
        return nil
    }
    
    func getJsonAsData(jsonObject json: Any) -> Data? {
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }

    func getJsonAsDictionary(with data: Data) -> NSDictionary? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                return json
            }
        } catch {
            print("JSON response parsing dictionary failure: \(error)")
        }
        return nil
    }
}
