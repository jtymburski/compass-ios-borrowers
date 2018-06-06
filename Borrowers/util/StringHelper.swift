//
//  StringHelper.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

struct StringHelper {
    static func append(appendTo: String, string: String, divider: String) -> String {
        if appendTo.isEmpty {
            return string
        } else {
            return appendTo + divider + string
        }
    }

    static func getDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }

    static func getDateString(_ timeSince1970: Int64) -> String {
        return getDateString(Date(timeIntervalSince1970: Double(timeSince1970 / 1000)))
    }

    static func hasContent(_ testStr: String?) -> Bool {
        return testStr != nil && !testStr!.isEmpty
    }

    static func isValidEmail(_ testStr: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return testStr != nil && NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: testStr)
    }

    // Note: This only is for north america strings. Evaluate in the future for international
    static func isValidPhone(_ testStr: String?) -> Bool {
        let phoneRegex = "(?:(?:\\+?1\\s*(?:[.-]\\s*)?)?(?:\\(\\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\\s*\\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\\s*(?:[.-]\\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\\s*(?:[.-]\\s*)?([0-9]{4})(?:\\s*(?:#|x\\.?|ext\\.?|extension)\\s*(\\d+))?"
        return testStr != nil && NSPredicate(format: "SELF MATCHES %@", phoneRegex).evaluate(with: testStr)
    }

    static func isValidPassword(_ testStr: String?, strong: Bool = false) -> Bool {
        return testStr != nil && testStr!.count > 0 && (strong ? testStr!.count >= 8 : true)
    }

    static func removeAllButNumeric(_ original: String?) -> String {
        if original != nil {
            return original!.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        }
        return ""
    }
}
