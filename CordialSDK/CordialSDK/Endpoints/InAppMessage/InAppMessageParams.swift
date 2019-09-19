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
    let height: Int16
    let top: Int16
    let right: Int16
    let bottom: Int16
    let left: Int16
    let displayType: InAppMessageDisplayType
    let expirationTime: Date?
    
    init(mcID: String, date: Date, type: InAppMessageType, height: Int16, top: Int16, right: Int16, bottom: Int16, left: Int16, displayType: InAppMessageDisplayType, expirationTime: Date?) {
        self.mcID = mcID
        self.date = date
        self.type = type
        self.height = height
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.displayType = displayType
        self.expirationTime = expirationTime
    }
}
