//
//  UIColorCompat.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-06-02.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import UIKit

class UIColorCompat {
    var color: UIColor!

    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        if #available(iOS 10, *) {
            color = UIColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
        } else {
            color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }

    func get() -> UIColor {
        return color
    }

    func getCG() -> CGColor {
        return color.cgColor
    }
}
