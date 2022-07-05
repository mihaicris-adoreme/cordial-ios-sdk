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

@objc public class NumericValue: NSObject, NSCoding, AttributeValue {
    
    public let value: Double
    
    enum Key: String {
        case value = "value"
    }
    
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeDouble(forKey: Key.value.rawValue)
        
        self.init(value)
    }
}

@objc public class BooleanValue: NSObject, NSCoding, AttributeValue {

    public let value: Bool
    
    enum Key: String {
        case value = "value"
    }
    
    @objc public init(_ value: Bool) {
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

@objc public class ArrayValue: NSObject, NSCoding, AttributeValue {
    
    public let value: [String]
    
    enum Key: String {
        case value = "value"
    }
    
    @objc public init(_ value: [String]) {
        self.value = value
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value =  coder.decodeObject(forKey: Key.value.rawValue) as? [String] ?? [String]()
        
        self.init(value)
    }
}

@objc public class StringValue: NSObject, NSCoding, AttributeValue {
    
    public let value: String
    
    enum Key: String {
        case value = "value"
    }
    
    @objc public init(_ value: String) {
        self.value = value
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? String ?? String()
        
        self.init(value)
    }
}

@objc public class DateValue: NSObject, NSCoding, AttributeValue {
    
    public let value: Date
    
    enum Key: String {
        case value = "value"
    }
    
    @objc public init(_ value: Date) {
        self.value = value
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.value, forKey: Key.value.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let value = coder.decodeObject(forKey: Key.value.rawValue) as? Date ?? Date()
        
        self.init(value)
    }
}

@objc public class GeoValue: NSObject, NSCoding, AttributeValue {
    
    var city = String()
    var country = String()
    var postalCode = String()
    var state = String()
    var streetAddress = String()
    var streetAddress2 = String()
    var timeZone = String()
    
    enum Key: String {
        case city = "city"
        case country = "country"
        case postalCode = "postalCode"
        case state = "state"
        case streetAddress = "streetAddress"
        case streetAddress2 = "streetAddress2"
        case timeZone = "timeZone"
    }
    
    @objc public override init() {}
    
    private init(city: String, country: String, postalCode: String, state: String, streetAddress: String, streetAddress2: String, timeZone: String) {
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.state = state
        self.streetAddress = streetAddress
        self.streetAddress2 = streetAddress2
        self.timeZone = timeZone
    }
    
    @objc public func setCity(_ city: String) {
        self.city = city
    }
    
    @objc public func setCountry(_ country: String) {
        self.country = country
    }
    
    @objc public func setPostalCode(_ postalCode: String) {
        self.postalCode = postalCode
    }
    
    @objc public func setState(_ state: String) {
        self.state = state
    }
    
    @objc public func setStreetAddress(_ streetAddress: String) {
        self.streetAddress = streetAddress
    }
    
    @objc public func setStreetAddress2(_ streetAddress2: String) {
        self.streetAddress2 = streetAddress2
    }
    
    @objc public func setTimeZone(_ timeZone: String) {
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.city, forKey: Key.city.rawValue)
        coder.encode(self.country, forKey: Key.country.rawValue)
        coder.encode(self.postalCode, forKey: Key.postalCode.rawValue)
        coder.encode(self.state, forKey: Key.state.rawValue)
        coder.encode(self.streetAddress, forKey: Key.streetAddress.rawValue)
        coder.encode(self.streetAddress2, forKey: Key.streetAddress2.rawValue)
        coder.encode(self.timeZone, forKey: Key.timeZone.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        let city = coder.decodeObject(forKey: Key.city.rawValue) as? String ?? String()
        let country = coder.decodeObject(forKey: Key.country.rawValue) as? String ?? String()
        let postalCode = coder.decodeObject(forKey: Key.postalCode.rawValue) as? String ?? String()
        let state = coder.decodeObject(forKey: Key.state.rawValue) as? String ?? String()
        let streetAddress = coder.decodeObject(forKey: Key.streetAddress.rawValue) as? String ?? String()
        let streetAddress2 = coder.decodeObject(forKey: Key.streetAddress2.rawValue) as? String ?? String()
        let timeZone = coder.decodeObject(forKey: Key.timeZone.rawValue) as? String ?? String()
        
        self.init(city: city, country: country, postalCode: postalCode, state: state, streetAddress: streetAddress, streetAddress2: streetAddress2, timeZone: timeZone)
    }
}
