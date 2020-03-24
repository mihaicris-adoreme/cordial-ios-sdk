//
//  AttributeGeo.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 24.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class GeoAttribute {
    
    let key: String
    let city: String
    let country: String
    let postalCode: String
    let state: String
    let streetAdress: String
    let streetAdress2: String
    let timeZone: String
    
    init(key: String, city: String, country: String, postalCode: String, state: String, streetAdress: String, streetAdress2: String, timeZone: String) {
        self.key = key
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.state = state
        self.streetAdress = streetAdress
        self.streetAdress2 = streetAdress2
        self.timeZone = timeZone
    }
    
}
