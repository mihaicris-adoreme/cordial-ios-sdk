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

@objc class OSLogManager: NSObject, LoggerDelegate {
    
    @objc static let shared = OSLogManager()
    
    private override init() {}
    
    private let subsystem = Bundle.main.bundleIdentifier!
    private var categories: [String: OSLog] = [:]
    
    private func getOSLogCategory(category: String) -> OSLog {
        if let categoryOSLog = self.categories[category] {
            return categoryOSLog
        }
        
        let categoryOSLog = OSLog(subsystem: self.subsystem, category: category)
        self.categories[category] = categoryOSLog
        
        return categoryOSLog
    }
    
    // MARK: - LoggerDelegate
    
    public func log(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .default, message)
    }
    
    public func info(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .info, message)
    }
    
    public func debug(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .debug, message)
    }
    
    public func error(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .error, message)
    }
    
    public func fault(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .fault, message)
    }
}
