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
    let streetAddress: String
    let streetAddress2: String
    let timeZone: String
    
    init(key: String, city: String, country: String, postalCode: String, state: String, streetAddress: String, streetAddress2: String, timeZone: String) {
        self.key = key
        self.city = city
        self.country = country
        self.postalCode = postalCode
        self.state = state
        self.streetAddress = streetAddress
        self.streetAddress2 = streetAddress2
        self.timeZone = timeZone
    }
    
}
