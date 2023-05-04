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
    
    static let cordialInfo = OSLog(subsystem: subsystem, category: "CordialSDKInfo")
    static let cordialError = OSLog(subsystem: subsystem, category: "CordialSDKError")
    
    static let cordialCoreDataError = OSLog(subsystem: subsystem, category: "CordialSDKCoreDataError")
    
    static let cordialPushNotification = OSLog(subsystem: subsystem, category: "CordialSDKPushNotification")
    static let cordialPushNotificationCarousel = OSLog(subsystem: subsystem, category: "CordialSDKPushNotificationCarousel")
    
    static let cordialBackgroundURLSession = OSLog(subsystem: subsystem, category: "CordialSDKBackgroundURLSession")
    static let cordialDeepLinks = OSLog(subsystem: subsystem, category: "CordialSDKDeepLinks")
    
    static let cordialSendCustomEvents = OSLog(subsystem: subsystem, category: "CordialSDKSendCustomEvents")
    static let cordialUpsertContactCart = OSLog(subsystem: subsystem, category: "CordialSDKUpsertContactCart")
    static let cordialSendContactOrders = OSLog(subsystem: subsystem, category: "CordialSDKSendContactOrders")
    static let cordialUpsertContacts = OSLog(subsystem: subsystem, category: "CordialSDKUpsertContacts")
    static let cordialSendContactLogout = OSLog(subsystem: subsystem, category: "CordialSDKSendContactLogout")
    static let cordialInAppMessage = OSLog(subsystem: subsystem, category: "CordialSDKInAppMessage")
    static let cordialInAppMessageContent = OSLog(subsystem: subsystem, category: "CordialSDKInAppMessageContent")
    static let cordialInAppMessages = OSLog(subsystem: subsystem, category: "CordialSDKInAppMessages")
    static let cordialSecurity = OSLog(subsystem: subsystem, category: "CordialSDKSecurity")
    static let cordialInboxMessages = OSLog(subsystem: subsystem, category: "CordialSDKInboxMessages")
    static let cordialContactTimestamps = OSLog(subsystem: subsystem, category: "CordialSDKContactTimestamps")
    
}

// TMP public control access – Major update should delete it as `osLogLevel` and `osLogManager`
@objc public class OSLogManager: NSObject, LoggerDelegate {
    
    @objc static let shared = OSLogManager()
    
    private override init() {}
    
    // MARK: - LoggerDelegate
    
    public func log(_ message: String) {
        os_log("%s", log: .default, type: .default, message)
    }
    
    public func info(_ message: String) {
        os_log("%s", log: .default, type: .info, message)
    }
    
    public func debug(_ message: String) {
        os_log("%s", log: .default, type: .debug, message)
    }
    
    public func error(_ message: String) {
        os_log("%s", log: .default, type: .error, message)
    }
    
    public func fault(_ message: String) {
        os_log("%s", log: .default, type: .fault, message)
    }
}
