//
//  InAppMessageParams.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct InAppMessageParams {
    let mcID: String
    let date: Date
    let type: InAppMessageType
    let top: Int16
    let right: Int16
    let bottom: Int16
    let left: Int16
    let displayType: InAppMessageDisplayType
    let expirationTime: Date?
    let inactiveSessionDisplay: InAppMessageInactiveSessionDisplayType
    
    init(mcID: String, date: Date, type: InAppMessageType, top: Int16, right: Int16, bottom: Int16, left: Int16, displayType: InAppMessageDisplayType, expirationTime: Date?, inactiveSessionDisplay: InAppMessageInactiveSessionDisplayType) {
        self.mcID = mcID
        self.date = date
        self.type = type
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.displayType = displayType
        self.expirationTime = expirationTime
        self.inactiveSessionDisplay = inactiveSessionDisplay
    }
}
