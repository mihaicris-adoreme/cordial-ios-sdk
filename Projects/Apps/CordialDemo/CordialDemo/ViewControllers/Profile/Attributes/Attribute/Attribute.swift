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
    let value: [String?]
    
    init(key: String, type: AttributeType, value: String?) {
        self.key = key
        self.type = type
        
        switch type {
        case AttributeType.array:
            if let value = value {
                self.value = Attribute.performStringSeparatedByCommaToArray(value)
            } else {
                self.value = [value]
            }
        default:
            self.value = [value]
        }
    }
    
    private static func performStringSeparatedByCommaToArray(_ string: String) -> [String] {
        var values = [String]()
        
        string.components(separatedBy: ",").forEach { value in
            values.append(value.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        return values
    }
    
    static func performArrayToStringSeparatedByComma(_ values: [String?]) -> String {
        var returnValue = String()
        
        values.forEach { value in
            if let value = value {
                returnValue.append("\(value), ")
            } else {
                returnValue.append("null, ")
            }
        }
        
        return returnValue
    }
    
    static func getArrayValue(_ values: [String?]) -> [String] {
        var returnValue = [String]()
        
        values.forEach { value in
            if let value = value {
                returnValue.append(value)
            }
        }
        
        return returnValue
    }
}
