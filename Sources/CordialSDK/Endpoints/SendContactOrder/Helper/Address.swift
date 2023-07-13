//
//  Address.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class Address: NSObject, NSCoding, NSSecureCoding {
    
    public static var supportsSecureCoding = true
    
    let name: String
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    var isError = false
    
    enum Key: String {
        case name = "name"
        case address = "address"
        case city = "city"
        case state = "state"
        case postalCode = "postalCode"
        case country = "country"
    }
    
    public init(name: String, address: String, city: String, state: String, postalCode: String, country: String) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: Key.name.rawValue)
        coder.encode(self.address, forKey: Key.address.rawValue)
        coder.encode(self.city, forKey: Key.city.rawValue)
        coder.encode(self.state, forKey: Key.state.rawValue)
        coder.encode(self.postalCode, forKey: Key.postalCode.rawValue)
        coder.encode(self.country, forKey: Key.country.rawValue)
    }
    
    public required convenience init?(coder: NSCoder) {
        if let name = coder.decodeObject(forKey: Key.name.rawValue) as? String,
           let address = coder.decodeObject(forKey: Key.address.rawValue) as? String,
           let city = coder.decodeObject(forKey: Key.city.rawValue) as? String,
           let state = coder.decodeObject(forKey: Key.state.rawValue) as? String,
           let postalCode = coder.decodeObject(forKey: Key.postalCode.rawValue) as? String,
           let country = coder.decodeObject(forKey: Key.country.rawValue) as? String {
            
            self.init(name: name, address: address, city: city, state: state, postalCode: postalCode, country: country)
        } else {
            self.init(name: String(), address: String(), city: String(), state: String(), postalCode: String(), country: String())
            
            self.isError = true
        }
    }
}
