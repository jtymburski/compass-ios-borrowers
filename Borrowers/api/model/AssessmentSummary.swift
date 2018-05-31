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

    private let RATING_VERY_STRONG = 1 // A+
    private let RATING_STRONG = 2 // A
    private let RATING_GREAT = 3 // A-
    private let RATING_GOOD = 4 // B+
    private let RATING_AVERAGE = 5 // B

    private let STATUS_STARTED = 1
    private let STATUS_APPROVED = 3

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

    func getRatingLetter() -> String {
        switch rating {
        case .some(RATING_VERY_STRONG),
             .some(RATING_STRONG),
             .some(RATING_GREAT):
            return "A"
        case .some(RATING_GOOD),
             .some(RATING_AVERAGE):
            return "B"
        default:
            return "--"
        }
    }

    func getRatingMod() -> String {
        switch rating {
        case .some(RATING_VERY_STRONG),
             .some(RATING_GOOD):
            return "+"
        case .some(RATING_GREAT):
            return "-"
        default:
            return ""
        }
    }

    func isApproved() -> Bool {
        return status != nil && status == STATUS_APPROVED
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
