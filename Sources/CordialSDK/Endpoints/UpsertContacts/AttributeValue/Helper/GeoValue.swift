//
//  GeoValue.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.09.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc public class GeoValue: NSObject, NSCoding, NSSecureCoding, AttributeValue, JSONValue {
    
    @objc public static var supportsSecureCoding = true
    
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
    
    @objc public func getCity() -> String {
        return self.city
    }
    
    @objc public func getCountry() -> String {
        return self.country
    }
    
    @objc public func getPostalCode() -> String {
        return self.postalCode
    }
    
    @objc public func getState() -> String {
        return self.state
    }
    
    @objc public func getStreetAddress() -> String {
        return self.streetAddress
    }
    
    @objc public func getStreetAddress2() -> String {
        return self.streetAddress2
    }
    
    @objc public func getTimeZone() -> String {
        return self.timeZone
    }
    
    @objc public func encode(with coder: NSCoder) {
        coder.encode(self.city, forKey: Key.city.rawValue)
        coder.encode(self.country, forKey: Key.country.rawValue)
        coder.encode(self.postalCode, forKey: Key.postalCode.rawValue)
        coder.encode(self.state, forKey: Key.state.rawValue)
        coder.encode(self.streetAddress, forKey: Key.streetAddress.rawValue)
        coder.encode(self.streetAddress2, forKey: Key.streetAddress2.rawValue)
        coder.encode(self.timeZone, forKey: Key.timeZone.rawValue)
    }
    
    @objc public required convenience init?(coder: NSCoder) {
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
