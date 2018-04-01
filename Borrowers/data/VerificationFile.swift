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
    private let CONTENT_TYPE = "image/jpeg"
    private let JPEG_QUALITY: CGFloat = 0.7

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

    func getAssessmentFile() -> AssessmentFile {
        return AssessmentFile.init(fileName: name, contentType: CONTENT_TYPE, uploaded: Int64(Date().timeIntervalSince1970))
    }

    func getContentType() -> String {
        return CONTENT_TYPE
    }

    func getData() -> Data? {
        if isValid() {
            return UIImageJPEGRepresentation(image!, JPEG_QUALITY)
        }
        return nil
    }

    func set(image: UIImage, name: String) {
        self.image = image
        self.name = name
    }
}
