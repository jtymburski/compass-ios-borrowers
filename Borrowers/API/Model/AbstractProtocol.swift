//
//  AbstractModel.swift
//  Borrowers
//
//  Created by Kevin Smith on 2018-03-07.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import Foundation

protocol AbstractProtocol {
    func isValid() -> Bool
    func parse(_ data: Data)
}
