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
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    let initNotificationManager = NotificationManager.shared
    let initInAppMessageProcess = InAppMessageProcess.shared
    let initCoreDataManager = CoreDataManager.shared
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    let cordialSwizzler = CordialSwizzler()
    let cordialPushNotification = CordialPushNotification()
    let cordialPushNotificationHandler = CordialPushNotificationHandler()
    
    @objc public let osLogManager = CordialOSLogManager()
    
    @objc public var cordialDeepLinksDelegate: CordialDeepLinksDelegate?
    @objc public var pushNotificationDelegate: CordialPushNotificationDelegate?
    @objc public var pushesConfiguration: CordialPushNotificationType = .SDK
    
    @objc public var qtyCachedEventQueue = 1000
    @objc public var systemEventsProperties: Dictionary<String, String>?
    
    @objc public var vanityDomains = [String]()
    
    @objc public var eventsBulkSize: Int = 1 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet(newEventsBulkSize) {
            if eventsBulkSize != newEventsBulkSize && newEventsBulkSize.signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }
    
    @objc public var eventsBulkUploadInterval: TimeInterval = 30 {
        didSet {
            CoreDataManager.shared.coreDataSender.startSendCachedCustomEventRequestsScheduledTimer()
        }
        willSet(newEventsBulkUploadInterval) {
            if eventsBulkUploadInterval != newEventsBulkUploadInterval && Int(newEventsBulkUploadInterval).signum() == 1 {
                CoreDataManager.shared.coreDataSender.canBeStartedCachedEventsScheduledTimer = true
            }
        }
    }

    @objc public let inAppMessageDelayMode = InAppMessageDelayMode()
    
    private override init(){
        self.cordialPushNotification.getNotificationSettings()
    }
    
    @objc public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.cordial.com/"
        
//        CoreDataManager.shared.deleteAllCoreData()
        
        InternalCordialAPI().prepareDeviceIdentifier()
        
    }
    
    @objc public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        CordialLocationManager.shared.untilTraveled = untilTraveled
        CordialLocationManager.shared.timeout = timeout
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
    
}
