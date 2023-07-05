//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation

@objc public class CordialApiConfiguration: NSObject {
    
    @objc public static let shared = CordialApiConfiguration()
    
    private override init() {}
    
    let sdkVersion = "4.2.1"
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    let initInAppMessageProcess = InAppMessageProcess.shared
    
    internal var accountKey = String()
    internal var channelKey = String()
    internal var eventsStreamURL = String()
    internal var messageHubURL = String()
    
    @available(*, deprecated, message: "Use loggerManager instead")
    @objc public let osLogManager = LoggerManager.shared
    
    @objc public let loggerManager = LoggerManager.shared
    
    @objc public var cordialDeepLinksDelegate: CordialDeepLinksDelegate?
    @objc public var pushNotificationDelegate: CordialPushNotificationDelegate?
    @objc public var pushNotificationCategoriesDelegate: PushNotificationCategoriesDelegate?
    @objc public var inAppMessageInputsDelegate: InAppMessageInputsDelegate?
    @objc public var inboxMessageDelegate: InboxMessageDelegate?
    
    @objc public var pushesConfiguration: CordialPushNotificationConfigurationType = .SDK
    @objc public var deepLinksConfiguration: CordialDeepLinksConfigurationType = .SDK
    @objc public var backgroundURLSessionConfiguration: CordialURLSessionConfigurationType = .SDK
    @objc public var pushNotificationCategoriesConfiguration: PushNotificationCategoriesConfigurationType = .SDK
    @objc public var inAppMessagesDeliveryConfiguration: InAppMessagesDeliveryConfigurationType = .directDelivery
    
    @objc public let inboxMessageCache = InboxMessageCache.shared
    
    @objc public var qtyCachedEventQueue = 1000
    @objc public var systemEventsProperties: Dictionary<String, Any>?
    
    @objc public func setNotificationCategories(_ pushNotificationCategories: [PushNotificationCategory]) {
        let internalCordialAPI = InternalCordialAPI()
        
        if !pushNotificationCategories.isEmpty {
            if internalCordialAPI.isNewPushNotificationCategories(pushNotificationCategories: pushNotificationCategories) {
                internalCordialAPI.setPushNotificationCategories(pushNotificationCategories: pushNotificationCategories)
                internalCordialAPI.setPushNotificationCategories(pushNotificationCategories: pushNotificationCategories, key: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CATEGORIES_ORIGIN)
            }
        } else {
            LoggerManager.shared.error(message: "Setting empty push notification categories array is unsupported", category: "CordialSDKPushNotification")
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
        LoggerManager.shared.log(message: "Device Identifier: [\(deviceID)] SDK: [\(self.sdkVersion)]", category: "CordialSDKInfo")
        
        self.systemEventsProperties = InternalCordialAPI().getMergedDictionaryToSystemEventsProperties(properties: ["deviceId": deviceID])
        
        CoreDataManager.shared.customEventRequests.updateSendingCustomEventRequestsIfNeeded()
        
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
