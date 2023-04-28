//
//  CordialOSLogManager.swift
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

@objc public enum logLevel: Int {
    case none
    case all
    case error
    case info 
}

public enum osLogLevel: String {
    case none = "none"
    case all = "all"
    case error = "error"
    case info = "info"
}

@objc public class CordialOSLogManager: NSObject {
    
    @objc static let shared = CordialOSLogManager()
    
    private override init() {}
        
    var currentOSLogLevel = osLogLevel.error
    
    @objc public func setLogLevel(_ logLevel: logLevel) {
        switch logLevel {
        case .none:
            self.setOSLogLevel(osLogLevel.none)
        case .all:
            self.setOSLogLevel(osLogLevel.all)
        case .error:
            self.setOSLogLevel(osLogLevel.error)
        case .info:
            self.setOSLogLevel(osLogLevel.info)
        }
    }
    
    public func setOSLogLevel(_ osLogLevel: osLogLevel) {
        switch osLogLevel {
        case .none:
            self.currentOSLogLevel = .none
        case .all:
            self.currentOSLogLevel = .all
        case .error:
            self.currentOSLogLevel = .error
        case .info:
            self.currentOSLogLevel = .info
        }
    }
    
    func logging(_ message: StaticString, log: OSLog, type: osLogLevel, _ args: CVarArg...) {
        if self.isAvailableOsLogLevelForPrint(type) {
            os_log(message, log: log, type: self.getOSLogType(type), args)
        }
    }
    
    private func getOSLogType(_ osLogLevel: osLogLevel) -> OSLogType {
        switch osLogLevel {
        case .error:
            return .error
        default:
            return .info
        }
    }
    
    private func isAvailableOsLogLevelForPrint(_ osLogLevel: osLogLevel) -> Bool {
        switch self.currentOSLogLevel {
        case .none:
            return false
        case .all:
            return true
        default: break
        }
        
        switch osLogLevel {
        case .error:
            return true
        case .info:
            if self.currentOSLogLevel == .info {
                return true
            }
        default: break
        }
        
        return false
    }
}
