//
//  StringHelper.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

struct StringHelper {
    static func isValidEmail(_ testStr: String?) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return testStr != nil && NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: testStr)
    }
    
    static func isValidPassword(_ testStr: String?, strong: Bool = false) -> Bool {
        return testStr != nil && testStr!.count > 0 && (strong ? testStr!.count > 8 : true)
    }
}
