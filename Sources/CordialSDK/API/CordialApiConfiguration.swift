//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

@objcMembers public class CordialApiConfiguration: NSObject {
    
    public static let shared = CordialApiConfiguration()
    
    private override init() {}
    
    let sdkVersion = "4.4.5"
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    let initInAppMessageProcess = InAppMessageProcess.shared
    
    var accountKey = String()
    var channelKey = String()
    var eventsStreamURL = String()
    var messageHubURL = String()
    
    @available(*, deprecated, message: "Use loggerManager instead")
    public let osLogManager = LoggerManager.shared
    
    public let loggerManager = LoggerManager.shared
    
    public var cordialDeepLinksDelegate: CordialDeepLinksDelegate?
    public var pushNotificationDelegate: CordialPushNotificationDelegate?
    public var pushNotificationCategoriesDelegate: PushNotificationCategoriesDelegate?
    public var inAppMessageInputsDelegate: InAppMessageInputsDelegate?
    public var inboxMessageDelegate: InboxMessageDelegate?
    
    public var pushesConfiguration: CordialPushNotificationConfigurationType = .SDK
    public var deepLinksConfiguration: CordialDeepLinksConfigurationType = .SDK
    public var backgroundURLSessionConfiguration: CordialURLSessionConfigurationType = .SDK
    public var pushNotificationCategoriesConfiguration: PushNotificationCategoriesConfigurationType = .SDK
    public var inAppMessagesDeliveryConfiguration: InAppMessagesDeliveryConfigurationType = .directDelivery
    
    public let inboxMessageCache = InboxMessageCache.shared
    public let inAppMessageDelayMode = InAppMessageDelayMode.shared
    
    public var qtyCachedEventQueue = 1000
    public var systemEventsProperties: Dictionary<String, Any>?
    
    public var vanityDomains: [String] = []
    
    public var keyWindow: UIWindow?
    
    public var inAppMessages: InAppMessagesConfig = InAppMessagesConfig(displayDelayInSeconds: 0.5)
    public class InAppMessagesConfig: NSObject {
        public var displayDelayInSeconds: Double

        init(displayDelayInSeconds: Double) {
            self.displayDelayInSeconds = displayDelayInSeconds
        }
    }

    public var cordialURLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: API.BACKGROUND_URL_SESSION_IDENTIFIER) {
        didSet {
            LoggerManager.shared.info(message: "SDK uses a passed URLSessionConfiguration setup", category: "CordialSDKInfo")
        }
    }
    
    public var eventsBulkSize: Int = 1 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet (newEventsBulkSize) {
            if eventsBulkSize != newEventsBulkSize && newEventsBulkSize.signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }
    
    public var eventsBulkUploadInterval: TimeInterval = 30 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet (newEventsBulkUploadInterval) {
            if eventsBulkUploadInterval != newEventsBulkUploadInterval && Int(newEventsBulkUploadInterval).signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }
    
    public func setNotificationCategories(_ pushNotificationCategories: [PushNotificationCategory]) {
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
    
    @available(iOS, deprecated, message: "Use initialize(accountKey:channelKey:eventsStreamURL:messageHubURL) instead")
    public func initialize(accountKey: String, channelKey: String) {
        self.initialize(accountKey: accountKey, channelKey: channelKey, eventsStreamURL: "https://events-stream-svc.cordial.com/")
    }

    public func initialize(accountKey: String, channelKey: String, eventsStreamURL: String, messageHubURL: String = "") {
        var eventsStreamURL = eventsStreamURL
        var messageHubURL = messageHubURL
        
        if eventsStreamURL.isEmpty {
            eventsStreamURL = "https://events-stream-svc.cordial.com/"
        } else if eventsStreamURL.last != "/" || eventsStreamURL.prefix(8) != "https://" {
            let prefix = (eventsStreamURL.prefix(8) != "https://") ? "https://" : ""
            let suffix = (eventsStreamURL.last != "/") ? "/" : ""
            
            eventsStreamURL = "\(prefix)\(eventsStreamURL)\(suffix)"
        }
        
        if messageHubURL.isEmpty {
            messageHubURL = eventsStreamURL.replacingFirstOccurrence(of: "events-stream", with: "message-hub")
        } else if messageHubURL.last != "/" || messageHubURL.prefix(8) != "https://" {
            let prefix = (messageHubURL.prefix(8) != "https://") ? "https://" : ""
            let suffix = (messageHubURL.last != "/") ? "/" : ""
            
            messageHubURL = "\(prefix)\(messageHubURL)\(suffix)"
        }
        
        if self.accountKey != accountKey || self.channelKey != channelKey || self.eventsStreamURL != eventsStreamURL || self.messageHubURL != messageHubURL {
            CoreDataManager.shared.deleteAll()
            CordialUserDefaults.deleteAll()
        }
        
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.eventsStreamURL = eventsStreamURL
        self.messageHubURL = messageHubURL
        
        let internalCordialAPI = InternalCordialAPI()
        
        let deviceID = internalCordialAPI.getDeviceIdentifier()
        LoggerManager.shared.log(message: "Device Identifier: [\(deviceID)] SDK: [\(self.sdkVersion)]", category: "CordialSDKInfo")
        
        self.systemEventsProperties = internalCordialAPI.getMergedDictionaryToSystemEventsProperties(properties: ["deviceId": deviceID])
        
        CoreDataManager.shared.updateSendingRequestsIfNeeded()
        
        CordialPushNotification.shared.setupPushNotifications()
        
        NotificationManager.shared.setupNotificationManager()
    }
    
    public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
    
    @available(iOS, deprecated, message: "Use initializeLocationManager(desiredAccuracy:distanceFilter:) instead")
    public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        CordialLocationManager.shared.untilTraveled = untilTraveled
        CordialLocationManager.shared.timeout = timeout
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
}

