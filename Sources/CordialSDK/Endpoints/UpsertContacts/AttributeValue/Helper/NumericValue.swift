//
//  NumericValue.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.09.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc public class NumericValue: NSObject, NSCoding, AttributeValue, JSONValue {
    
    public let value: Double?
    
    enum Key: String {
        case value = "value"
    }
    
    public init(_ value: Double?) {
        self.value = value
    }
    
    public init(_ value: Int?) {
        if let value = value {
            self.value = Double(value)
        } else {
            self.value = nil
        }
    }
    
    @objc public init(numberValue: NSNumber?) {
        self.value = numberValue?.doubleValue
    }
    
    @available(*, deprecated, message: "Use `initWithNumberValue` instead")
    @objc public init(doubleValue: Double) {
        self.value = doubleValue
    }
    
    @available(*, deprecated, message: "Use `initWithNumberValue` instead")
    @objc public init(intValue: Int) {
        self.value = Double(intValue)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? Double
        
        self.init(value)
    }
}
