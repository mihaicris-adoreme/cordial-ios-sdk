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

@objc public enum logLevel: Int {
    case none = 1
    case all = 2
    case error = 3
    case info = 4
}

public enum osLogLevel: String {
    case none = "none"
    case all = "all"
    case error = "error"
    case info = "info"
}

@objc public class CordialOSLogManager: NSObject {
        
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
    
    func isAvailableOsLogLevelForPrint(osLogLevel: osLogLevel) -> Bool {
        switch self.currentOSLogLevel {
        case .none:
            return false
        case .all:
            return true
        default: break
        }
        
        switch osLogLevel {
        case .error:
            if self.currentOSLogLevel == .error {
                return true
            }
        case .info:
            if self.currentOSLogLevel == .info {
                return true
            }
        default: break
        }
        
        return false
    }
}
