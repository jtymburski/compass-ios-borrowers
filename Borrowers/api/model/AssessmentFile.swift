//
//  AssessmentFile.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-31.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

class AssessmentFile: BaseModel, AbstractProtocol, CustomStringConvertible {
    private let KEY_CONTENT_TYPE = "content_type"
    private let KEY_FILE_NAME = "file_name"
    private let KEY_UPLOADED = "uploaded"

    var contentType: String?
    var fileName: String?
    var uploaded: Int64?

    var description: String {
        return "AssessmentFile [ File Name : \(fileName ?? "nil") , Content Type : \(contentType ?? "nil") , Uploaded : \(uploaded ?? 0) ]"
    }

    init(_ data: Data) {
        super.init()
        parse(data)
    }

    init(_ json: NSDictionary) {
        super.init()
        parse(json)
    }

    init(fileName: String?, contentType: String?, uploaded: Int64?) {
        super.init()
        self.contentType = contentType
        self.fileName = fileName
        self.uploaded = uploaded
    }

    func isValid() -> Bool {
        return (contentType != nil && contentType!.count > 0 && fileName != nil && fileName!.count > 0 && uploaded != nil && uploaded! > 0)
    }

    func parse(_ data: Data) {
        if let json = getJsonAsDictionary(with: data) {
            parse(json)
        }
    }

    func parse(_ json: NSDictionary) {
        if let contentType = json.object(forKey: KEY_CONTENT_TYPE) as? String,
            let fileName = json.object(forKey: KEY_FILE_NAME) as? String,
            let uploaded = json.object(forKey: KEY_UPLOADED) as? NSNumber {

            self.contentType = contentType
            self.fileName = fileName
            self.uploaded = uploaded.int64Value
        }
    }

    func toJson() -> Any? {
        if isValid() {
            return [
                KEY_FILE_NAME : fileName!,
                KEY_CONTENT_TYPE : contentType!,
                KEY_UPLOADED : uploaded!
            ]
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
