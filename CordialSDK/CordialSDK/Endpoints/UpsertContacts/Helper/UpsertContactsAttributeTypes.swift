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
    
}

@objc public class BooleanValue: NSObject, AttributeValue {
    
    public let value: Bool
    
    public init(_ value: Bool) {
        self.value = value
    }
    
}

@objc public class ArrayValue: NSObject, AttributeValue {
    
    public let value: [String]
    
    public init(_ value: [String]) {
        self.value = value
    }
}

@objc public class StringValue: NSObject, AttributeValue {
    
    public let value: String
    
    public init(_ value: String) {
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
    var streetAdress = String()
    var streetAdress2 = String()
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
    
    public func setStreetAdress(_ streetAdress: String) {
        self.streetAdress = streetAdress
    }
    
    public func setStreetAdress2(_ streetAdress2: String) {
        self.streetAdress2 = streetAdress2
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
    
    public func getStreetAdress() -> String {
        return self.streetAdress
    }
    
    public func getStreetAdress2() -> String {
        return self.streetAdress2
    }
    
    public func getTimeZone() -> String {
        return self.timeZone
    }
}
