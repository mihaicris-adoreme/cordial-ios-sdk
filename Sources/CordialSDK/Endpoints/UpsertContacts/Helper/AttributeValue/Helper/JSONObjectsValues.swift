//
//  JSONObjectsValues.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc class JSONObjectsValues: NSObject, NSCoding, AttributeValue, JSONValue {
    
    var value: [JSONObjectValues]?
    
    enum Key: String {
        case value = "value"
    }
    
    @objc init(_ value: [JSONObjectValues]?) {
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? [JSONObjectValues]
        
        self.init(value)
    }
    
}
