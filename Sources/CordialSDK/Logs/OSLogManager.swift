//
//  OSLogManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

// OSLog Category
//
// CordialSDKDemo
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

class OSLogManager: LoggerDelegate {
    
    static let shared = OSLogManager()
    
    private init() {}
    
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
    
    func log(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .default, message)
    }
    
    func info(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .info, message)
    }
    
    func debug(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .debug, message)
    }
    
    func error(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .error, message)
    }
    
    func fault(message: String, category: String) {
        os_log("%{public}@", log: self.getOSLogCategory(category: category), type: .fault, message)
    }
}
