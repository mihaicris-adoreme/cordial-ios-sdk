//
//  Attribute.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 15.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class Attribute {

    let key: String
    let type: String
    let value: String
    
    init(key: String, type: String, value: String) {
        self.key = key
        self.type = type
        self.value = value
    }
}
