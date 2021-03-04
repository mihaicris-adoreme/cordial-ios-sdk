//
//  ContactTimestampURL.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class ContactTimestamp {
    
    let url: URL
    let expireDate: Date
    
    init(url: URL, expireDate: Date) {
        self.url = url
        self.expireDate = expireDate
    }
}
