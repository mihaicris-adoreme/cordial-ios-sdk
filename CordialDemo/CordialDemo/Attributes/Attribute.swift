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
    let type: AttributeType
    let value: String
    
    init(key: String, type: AttributeType, value: String) {
        self.key = key
        self.type = type
        self.value = value
    }
}

enum AttributeType: String {
    case string = "string"
    case boolean = "boolean"
    case numeric = "numeric"
    case array = "array"
}
