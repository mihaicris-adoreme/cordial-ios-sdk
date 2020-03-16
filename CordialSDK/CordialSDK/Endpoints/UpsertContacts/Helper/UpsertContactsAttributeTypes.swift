//
//  UpsertContactsAttributeTypes.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol AttributeValue {
    
}

@objc public class NumericValue: NSObject, AttributeValue {
    
    let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public init(_ value: Int) {
        self.value = Double(value)
    }
    
}

@objc public class BooleanValue: NSObject, AttributeValue {
    
    let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }
    
}

@objc public class ArrayValue: NSObject, AttributeValue {
    
    let value: [String]
    
    public init(_ value: [String]) {
        self.value = value
    }
}

@objc public class StringValue: NSObject, AttributeValue {
    
    let value: String
    
    public init(_ value: String) {
        self.value = value
    }
}
