//
//  UpsertContactsAttributes.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactsAttributes: NSObject, NSCoding {
    
    let attributes: Dictionary<String, AttributeValue>?
    
    var isError = false
    
    enum Key: String {
        case attributes = "attributes"
    }
    
    init(attributes: Dictionary<String, AttributeValue>?) {
        self.attributes = attributes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.attributes, forKey: Key.attributes.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let attributes = aDecoder.decodeObject(forKey: Key.attributes.rawValue) as? Dictionary<String, AttributeValue>? {
            
            self.init(attributes: attributes)
        } else {
            self.init(attributes: nil)
            
            self.isError = true
        }
    }
}
