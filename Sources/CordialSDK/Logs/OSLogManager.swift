//
//  OSLogManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

// Cordial OSLog
//
// CordialSDKInfo
// CordialSDKError
// CordialSDKCoreDataError
// CordialSDKPushNotification
// CordialSDKPushNotificationCarousel
// CordialSDKBackgroundURLSession
// CordialSDKDeepLinks
// CordialSDKSendCustomEvents
// CordialSDKUpsertContactCart
// CordialSDKSendContactOrders
// CordialSDKUpsertContacts
// CordialSDKSendContactLogout
// CordialSDKInAppMessage
// CordialSDKInAppMessageContent
// CordialSDKInAppMessages
// CordialSDKSecurity
// CordialSDKInboxMessages
// CordialSDKContactTimestamps

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
