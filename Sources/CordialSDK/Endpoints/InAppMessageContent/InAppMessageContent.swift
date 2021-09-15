//
//  InAppMessageContent.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 16.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageContent {
    
    let mcID: String
    let url: URL
    let expireDate: Date
    
    init(mcID: String, url: URL, expireDate: Date) {
        self.mcID = mcID
        self.url = url
        self.expireDate = expireDate
    }
}
