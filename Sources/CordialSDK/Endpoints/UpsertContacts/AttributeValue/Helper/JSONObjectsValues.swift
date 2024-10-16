//
//  JSONObjectsValues.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objcMembers class JSONObjectsValues: NSObject, NSCoding, NSSecureCoding, AttributeValue, JSONValue {
    
    static var supportsSecureCoding = true
    
    let value: Dictionary<String, [JSONValue]>?
    
    enum Key: String {
        case value = "value"
    }
    
    init(_ value: Dictionary<String, [JSONValue]>?) {
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? Dictionary<String, [JSONValue]>
        
        self.init(value)
    }
    
}
