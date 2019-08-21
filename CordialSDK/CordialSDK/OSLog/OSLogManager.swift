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
    
    static let cordialPushNotification = OSLog(subsystem: subsystem, category: "CordialSDKPushNotification")
    
    static let cordialError = OSLog(subsystem: subsystem, category: "CordialSDKError")
    
    static let cordialSendCustomEvents = OSLog(subsystem: subsystem, category: "CordialSDKSendCustomEvents")
    static let cordialUpsertContactCart = OSLog(subsystem: subsystem, category: "CordialSDKUpsertContactCart")
    static let cordialSendContactOrders = OSLog(subsystem: subsystem, category: "CordialSDKSendContactOrders")
    static let cordialUpsertContacts = OSLog(subsystem: subsystem, category: "CordialSDKUpsertContacts")
    static let cordialSendContactLogout = OSLog(subsystem: subsystem, category: "CordialSDKSendContactLogout")
    static let cordialInAppMessage = OSLog(subsystem: subsystem, category: "CordialSDKInAppMessage")
    static let cordialSDKSecurity = OSLog(subsystem: subsystem, category: "CordialSDKSecurity")
    
}

enum osLogLevel {
    
}

class OSLogManager {
    
    static let shared = OSLogManager()
    
    private init(){}
    
    
    
}
