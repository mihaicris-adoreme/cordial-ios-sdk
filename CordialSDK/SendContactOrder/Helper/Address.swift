//
//  Address.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class Address: NSObject, NSCoding {
    
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
    
    public init(name: String, address: String, city: String, state: String, postalCode: String, country: String) {
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Key.name.rawValue)
        aCoder.encode(address, forKey: Key.address.rawValue)
        aCoder.encode(city, forKey: Key.city.rawValue)
        aCoder.encode(state, forKey: Key.state.rawValue)
        aCoder.encode(postalCode, forKey: Key.postalCode.rawValue)
        aCoder.encode(country, forKey: Key.country.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let address = aDecoder.decodeObject(forKey: Key.address.rawValue) as! String
        let city = aDecoder.decodeObject(forKey: Key.city.rawValue) as! String
        let state = aDecoder.decodeObject(forKey: Key.state.rawValue) as! String
        let postalCode = aDecoder.decodeObject(forKey: Key.postalCode.rawValue) as! String
        let country = aDecoder.decodeObject(forKey: Key.country.rawValue) as! String
        
        self.init(name: name, address: address, city: city, state: state, postalCode: postalCode, country: country)
    }
}
