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
    let value: [String]
    
    init(key: String, type: AttributeType, value: String) {
        self.key = key
        self.type = type
        
        if type == AttributeType.array {
            self.value = Attribute.performStringSeparatedByCommaToArray(value)
        } else {
            self.value = [value]
        }
    }
    
    static func performStringSeparatedByCommaToArray(_ string: String) -> [String] {
        var values = [String]()
        
        string.components(separatedBy: ",").forEach { value in
            values.append(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return values
    }
    
    static func performArrayToStringSeparatedByComma(_ values: [String]) -> String {
        return values.joined(separator: ", ")
    }
}

enum AttributeType: String {
    case string = "string"
    case boolean = "boolean"
    case numeric = "numeric"
    case array = "array"
    case date = "date"
//    case geo = "geo"
}
