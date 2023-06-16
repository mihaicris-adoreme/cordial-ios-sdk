//
//  BooleanValue.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.09.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class BooleanValue: NSObject, NSCoding, NSSecureCoding, AttributeValue, JSONValue {
    
    public static var supportsSecureCoding = true

    public let value: Bool
    
    enum Key: String {
        case value = "value"
    }
    
    public init(_ value: Bool) {
        self.value = value
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeBool(forKey: Key.value.rawValue)
        
        self.init(value)
    }
}
