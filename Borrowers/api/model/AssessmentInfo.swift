//
//  AssessmentInfo.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class AssessmentInfo: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_FILES = "files"
    private let KEY_RATING = "rating"
    private let KEY_REFERENCE = "reference"
    private let KEY_REGISTERED = "registered"
    private let KEY_STATUS = "status"
    private let KEY_UPDATED = "updated"
    private let KEY_UPLOAD_PATH = "upload_path"

    private let MIN_FILE_COUNT = 4

    var files: [AssessmentFile]?
    var rating: Int?
    var reference: String?
    var registered: Int64?
    var status: Int?
    var updated: Int64?
    var uploadPath: String?

    // Control
    var referenceRequired = false

    var description: String {
        return "AssessmentInfo [ reference : \(reference ?? "nil") , registered : \(registered ?? 0) , updated : \(updated ?? 0) , status : \(status ?? 0) , rating : \(rating ?? 0) , upload path : \(uploadPath ?? "nil") ]"
    }

    init(_ data: Data, reference: String?) {
        super.init()
        self.reference = reference
        parse(data)
    }

    func hasUploadedFiles() -> Bool {
        return files != nil && files!.count >= MIN_FILE_COUNT
    }

    func isValid() -> Bool {
        return ((!referenceRequired || (reference != nil && NSUUID(uuidString: reference!) != nil)) && registered != nil && registered! > 0 && updated != nil && updated! > 0 && status != nil && status! > 0 && files != nil)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            if let files = json.object(forKey: KEY_FILES) as? NSArray,
                let registered = json.object(forKey: KEY_REGISTERED) as? NSNumber,
                let status = json.object(forKey: KEY_STATUS) as? NSNumber,
                let updated = json.object(forKey: KEY_UPDATED) as? NSNumber {

                // Reference test
                let reference = json.object(forKey: KEY_REFERENCE) as? String
                if self.reference != nil || reference != nil {
                    // Required
                    if reference != nil {
                        self.reference = reference
                    }
                    self.registered = registered.int64Value
                    self.status = status.intValue
                    self.updated = updated.int64Value

                    // Files
                    self.files = []
                    for object in files {
                        if let json = object as? NSDictionary {
                            self.files!.append(AssessmentFile.init(json))
                        }
                    }

                    // Optional
                    self.rating = (json.object(forKey: KEY_RATING) as? NSNumber)?.intValue
                    self.uploadPath = json.object(forKey: KEY_UPLOAD_PATH) as? String
                }
            }
        }
    }

    func setFiles(files: [VerificationFile]) {
        self.files = []
        for file in files {
            self.files!.append(file.getAssessmentFile())
        }
    }

    func toJson() -> Any? {
        if isValid() {
            let fileArray = NSMutableArray.init()
            for file in files! {
                if file.isValid() {
                    fileArray.add(file.toJson()!)
                }
            }

            let jsonData = NSMutableDictionary.init()
            jsonData.addEntries(from: [
                KEY_REFERENCE : reference!,
                KEY_REGISTERED : registered!,
                KEY_UPDATED : updated!,
                KEY_STATUS : status!,
                KEY_FILES : fileArray
            ])
            if rating != nil {
                jsonData.addEntries(from: [ KEY_RATING : rating! ])
            }
            if uploadPath != nil {
                jsonData.addEntries(from: [ KEY_UPLOAD_PATH : uploadPath! ])
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
