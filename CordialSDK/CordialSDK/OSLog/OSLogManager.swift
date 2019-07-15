//
//  OSLogManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

extension OSLog {
    
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let cordialPushNotification = OSLog(subsystem: subsystem, category: "CordialPushNotification")
    
    static let cordialError = OSLog(subsystem: subsystem, category: "CordialError")
    
    static let cordialSendCustomEvents = OSLog(subsystem: subsystem, category: "CordialSendCustomEvents")
    static let cordialUpsertContactCart = OSLog(subsystem: subsystem, category: "CordialUpsertContactCart")
    static let cordialSendContactOrders = OSLog(subsystem: subsystem, category: "CordialSendContactOrders")
    static let cordialUpsertContacts = OSLog(subsystem: subsystem, category: "CordialUpsertContacts")
    static let cordialSendContactLogout = OSLog(subsystem: subsystem, category: "CordialSendContactLogout")
    static let cordialFetchInAppMessage = OSLog(subsystem: subsystem, category: "CordialFetchInAppMessage")
    
}
