//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

@objc public class CordialApiConfiguration: NSObject {
    
    @objc public static let shared = CordialApiConfiguration()
    
    private override init() {}
    
    let sdkVersion = "4.1.5"
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    let initInAppMessageProcess = InAppMessageProcess.shared
    let initCoreDataManager = CoreDataManager.shared
    
    internal var accountKey = String()
    internal var channelKey = String()
    internal var eventsStreamURL = String()
    internal var messageHubURL = String()
    
    @objc public let osLogManager = CordialOSLogManager()
    
    @objc public var cordialDeepLinksDelegate: CordialDeepLinksDelegate?
    @objc public var pushNotificationDelegate: CordialPushNotificationDelegate?
    @objc public var inAppMessageInputsDelegate: InAppMessageInputsDelegate?
    @objc public var inboxMessageDelegate: InboxMessageDelegate?
    
    @objc public var pushesConfiguration: CordialPushNotificationConfigurationType = .SDK
    @objc public var deepLinksConfiguration: CordialDeepLinksConfigurationType = .SDK
    @objc public var backgroundURLSessionConfiguration: CordialURLSessionConfigurationType = .SDK
    @objc public var inAppMessagesDeliveryConfiguration: InAppMessagesDeliveryConfigurationType = .directDelivery
    
    @objc public let inboxMessageCache = InboxMessageCache.shared
    
    @objc public var qtyCachedEventQueue = 1000
    @objc public var systemEventsProperties: Dictionary<String, Any>?
    
    @objc public func setNotificationSettings(_ pushNotificationSettings: [PushNotificationSettings]) {
        let internalCordialAPI = InternalCordialAPI()
        
        if !pushNotificationSettings.isEmpty {
            if internalCordialAPI.isNewPushNotificationSettings(pushNotificationSettings: pushNotificationSettings) {
                internalCordialAPI.setPushNotificationSettings(pushNotificationSettings: pushNotificationSettings)
                internalCordialAPI.setPushNotificationSettings(pushNotificationSettings: pushNotificationSettings, key: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_SETTINGS_ORIGIN)
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Setting empty push notification settings array is unsupported", log: OSLog.cordialPushNotification, type: .error)
            }
        }
    }
    
    @objc public var vanityDomains = [String]()
    
    @objc public var eventsBulkSize: Int = 1 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet (newEventsBulkSize) {
            if eventsBulkSize != newEventsBulkSize && newEventsBulkSize.signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }
    
    @objc public var eventsBulkUploadInterval: TimeInterval = 30 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet (newEventsBulkUploadInterval) {
            if eventsBulkUploadInterval != newEventsBulkUploadInterval && Int(newEventsBulkUploadInterval).signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }

    @objc public let inAppMessageDelayMode = InAppMessageDelayMode()
    
    @objc public func initialize(accountKey: String, channelKey: String, eventsStreamURL: String = "", messageHubURL: String = "") {
        
        self.accountKey = accountKey
        self.channelKey = channelKey
        
        if eventsStreamURL.isEmpty {
            self.eventsStreamURL = "https://events-stream-svc.cordial.com/"
        } else if eventsStreamURL.last != "/" {
            self.eventsStreamURL = "\(eventsStreamURL)/"
        } else {
            self.eventsStreamURL = eventsStreamURL
        }
        
        if messageHubURL.isEmpty {
            self.messageHubURL = self.eventsStreamURL.replacingFirstOccurrence(of: "events-stream", with: "message-hub")
        } else if messageHubURL.last != "/" {
            self.messageHubURL = "\(messageHubURL)/"
        } else {
            self.messageHubURL = messageHubURL
        }
        
        let deviceID = InternalCordialAPI().getDeviceIdentifier()
        os_log("Device Identifier: [%{public}@] SDK: [%{public}@]", log: OSLog.cordialInfo, type: .info, deviceID, self.sdkVersion)
        
        CordialPushNotification.shared.setupPushNotifications()
        
        NotificationManager.shared.setupNotificationManager()
        
//        CoreDataManager.shared.deleteAllCoreData()
        
    }
    
    @objc public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        CordialLocationManager.shared.untilTraveled = untilTraveled
        CordialLocationManager.shared.timeout = timeout
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
    
}

