//
//  Address.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class Address: NSObject, NSCoding {
    
    let name: String
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    enum Key: String {
        case name = "name"
        case address = "address"
        case city = "city"
        case state = "state"
        case postalCode = "postalCode"
        case country = "country"
    }
    
    @objc public init(name: String, address: String, city: String, state: String, postalCode: String, country: String) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: Key.name.rawValue)
        aCoder.encode(self.address, forKey: Key.address.rawValue)
        aCoder.encode(self.city, forKey: Key.city.rawValue)
        aCoder.encode(self.state, forKey: Key.state.rawValue)
        aCoder.encode(self.postalCode, forKey: Key.postalCode.rawValue)
        aCoder.encode(self.country, forKey: Key.country.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let address = aDecoder.decodeObject(forKey: Key.address.rawValue) as! String
        let city = aDecoder.decodeObject(forKey: Key.city.rawValue) as! String
        let state = aDecoder.decodeObject(forKey: Key.state.rawValue) as! String
        let postalCode = aDecoder.decodeObject(forKey: Key.postalCode.rawValue) as! String
        let country = aDecoder.decodeObject(forKey: Key.country.rawValue) as! String
        
        self.init(name: name, address: address, city: city, state: state, postalCode: postalCode, country: country)
    }
}
