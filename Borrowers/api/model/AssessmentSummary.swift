//
//  AssessmentSummary.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-04-01.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class AssessmentSummary: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_DATE = "date"
    private let KEY_RATING = "rating"
    private let KEY_REFERENCE = "reference"
    private let KEY_STATUS = "status"

    private let STATUS_STARTED = 1

    var date: Int64?
    var rating: Int?
    var reference: String?
    var status: Int?

    var description: String {
        return "AssessmentSummary [ reference : \(reference ?? "nil") , date : \(date ?? 0) , status : \(status ?? 0) , rating : \(rating ?? 0) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    func isStarted() -> Bool {
        return status != nil && status == STATUS_STARTED
    }

    func isValid() -> Bool {
        return (reference != nil && NSUUID(uuidString: reference!) != nil && date != nil && date! > 0 && status != nil && status! > 0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let date = json.object(forKey: KEY_DATE) as? NSNumber,
            let reference = json.object(forKey: KEY_REFERENCE) as? String,
            let status = json.object(forKey: KEY_STATUS) as? NSNumber {

            // Required
            self.date = date.int64Value
            self.reference = reference
            self.status = status.intValue

            // Optional
            self.rating = (json.object(forKey: KEY_RATING) as? NSNumber)?.intValue
        }
    }

    func toJson() -> Any? {
        if isValid() {
            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_REFERENCE : reference!,
                KEY_DATE : date!,
                KEY_STATUS : status!
                ])
            if rating != nil {
                jsonData.addEntries(from: [ KEY_RATING : rating! ])
            }

            return jsonData
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
