//
//  UpsertContactsAttributes.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactsAttributes: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding = true
    
    let attributes: Dictionary<String, AttributeValue>?
    
    var isError = false
    
    enum Key: String {
        case attributes = "attributes"
    }
    
    init(attributes: Dictionary<String, AttributeValue>?) {
        self.attributes = attributes
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        if let attributes = coder.decodeObject(forKey: Key.attributes.rawValue) as? Dictionary<String, AttributeValue>? {
            
            self.init(attributes: attributes)
        } else {
            self.init(attributes: nil)
            
            self.isError = true
        }
    }
}
