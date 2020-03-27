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
    
    public let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public init(_ value: Int) {
        self.value = Double(value)
    }
    
    @objc public init(doubleValue: Double) {
        self.value = doubleValue
    }
    
    @objc public init(intValue: Int) {
        self.value = Double(intValue)
    }
    
}

@objc public class BooleanValue: NSObject, AttributeValue {
    
    public let value: Bool
    
    @objc public init(_ value: Bool) {
        self.value = value
    }
    
}

@objc public class ArrayValue: NSObject, AttributeValue {
    
    public let value: [String]
    
    @objc public init(_ value: [String]) {
        self.value = value
    }
}

@objc public class StringValue: NSObject, AttributeValue {
    
    public let value: String
    
    @objc public init(_ value: String) {
        self.value = value
    }
}

@objc public class DateValue: NSObject, AttributeValue {
    
    public let value: Date
    
    public init(_ value: Date) {
        self.value = value
    }
    
}

@objc public class GeoValue: NSObject, AttributeValue {
    
    var city = String()
    var country = String()
    var postalCode = String()
    var state = String()
    var streetAddress = String()
    var streetAddress2 = String()
    var timeZone = String()
    
    public func setCity(_ city: String) {
        self.city = city
    }
    
    public func setCountry(_ country: String) {
        self.country = country
    }
    
    public func setPostalCode(_ postalCode: String) {
        self.postalCode = postalCode
    }
    
    public func setState(_ state: String) {
        self.state = state
    }
    
    public func setStreetAddress(_ streetAddress: String) {
        self.streetAddress = streetAddress
    }
    
    public func setStreetAddress2(_ streetAddress2: String) {
        self.streetAddress2 = streetAddress2
    }
    
    public func setTimeZone(_ timeZone: String) {
        self.timeZone = timeZone
    }
    
    public func getCity() -> String {
        return self.city
    }
    
    public func getCountry() -> String {
        return self.country
    }
    
    public func getPostalCode() -> String {
        return self.postalCode
    }
    
    public func getState() -> String {
        return self.state
    }
    
    public func getStreetAddress() -> String {
        return self.streetAddress
    }
    
    public func getStreetAddress2() -> String {
        return self.streetAddress2
    }
    
    public func getTimeZone() -> String {
        return self.timeZone
    }
}
