//
//  DateValue.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.09.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc public class DateValue: NSObject, NSCoding, AttributeValue {
    
    public let value: Date?
    
    enum Key: String {
        case value = "value"
    }
    
    @objc public init(_ value: Date?) {
        self.value = value
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? Date 
        
        self.init(value)
    }
}
