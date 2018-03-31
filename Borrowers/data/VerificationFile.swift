//
//  VerificationFile.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation
import UIKit

class VerificationFile {
    var image: UIImage?
    var name: String?

    init() {
    }

    init(image: UIImage, name: String) {
        set(image: image, name: name)
    }

    func isValid() -> Bool {
        return image != nil && name != nil
    }

    func set(image: UIImage, name: String) {
        self.image = image
        self.name = name
    }
}
