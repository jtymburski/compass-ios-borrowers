//
//  AbstractModel.swift
//  Borrowers
//
//  Created by Kevin Smith on 2018-03-07.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class BaseModel {
    func getJsonAsArray(with data: Data) -> NSArray? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray {
                return json
            }
        } catch {
            print("JSON response parsing array failure: \(error)")
        }
        return nil
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
