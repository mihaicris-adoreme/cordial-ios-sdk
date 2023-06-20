//
//  JSONObjectValue.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objcMembers class JSONObjectValue: NSObject, NSCoding, NSSecureCoding, AttributeValue, JSONValue {
    
    static var supportsSecureCoding = true
    
    let value: Dictionary<String, AttributeValue>?
    
    enum Key: String {
        case value = "value"
    }
    
    init(_ value: Dictionary<String, AttributeValue>?) {
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? Dictionary<String, AttributeValue>
        
        self.init(value)
    }
    
}
