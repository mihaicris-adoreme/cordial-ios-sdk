//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

public class CordialApiConfiguration {
    
    public static let shared = CordialApiConfiguration()
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    
    public var qtyCachedEventQueue = 1000
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    let cordialSwizzler = CordialSwizzler()
    
    public var continueRestorationHandler: CordialContinueRestorationDelegate?
    public var openOptionsHandler: CordialOpenOptionsDelegate?
    public var pushNotificationHandler: CordialPushNotificationDelegate?
    
    let cordialPushNotification = CordialPushNotification()
    
    private init(){}
    
    public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.skrivobocheck.cordialdev.com/"
        
//        CoreDataManager.shared.deleteAllCoreData()
        
        self.prepareDeviceIdentifier()
        
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.FIRST_LAUNCH_EVENT_NAME
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
        
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIApplication.didFinishLaunchingNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAppDidFinishLaunchingNotification), name: UIApplication.didFinishLaunchingNotification, object: nil)
    }
    
    public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        CordialLocationManager.shared.untilTraveled = untilTraveled
        CordialLocationManager.shared.timeout = timeout
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
    
    func prepareDeviceIdentifier() {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString {
            UserDefaults.standard.set(deviceID, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        } else {
            UserDefaults.standard.set(UUID().uuidString, forKey: API.USER_DEFAULTS_KEY_FOR_DEVICE_ID)
        }
    }
    
    @objc func appMovedToBackground() {
        let eventName = API.APP_MOVED_TO_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func appMovedFromBackground() {
        let eventName = API.APP_MOVED_FROM_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.prepareCurrentSubscribeStatus()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
        
        self.showInAppMessages()
    }
    
    private func prepareCurrentSubscribeStatus() {
        let current = UNUserNotificationCenter.current()
        
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .authorized {
                if API.PUSH_NOTIFICATION_STATUS_ALLOW != UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) {
                    let upsertContactRequest = UpsertContactRequest(status: API.PUSH_NOTIFICATION_STATUS_ALLOW)
                    CordialAPI().upsertContact(upsertContactRequest: upsertContactRequest)
                }
            } else {
                if API.PUSH_NOTIFICATION_STATUS_DISALLOW != UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) {
                    let upsertContactRequest = UpsertContactRequest(status: API.PUSH_NOTIFICATION_STATUS_DISALLOW)
                    CordialAPI().upsertContact(upsertContactRequest: upsertContactRequest)
                }
            }
        })
    }
    
    private func showInAppMessages() {
        if let inAppMessageData = CoreDataManager.shared.inAppMessagesCache.getInAppMessageDataFromCoreData() {
            CordialAPI().showInAppMessagePopup(html: inAppMessageData.html)
        }
    }
    
    @objc func handleAppDidFinishLaunchingNotification(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        
        self.cordialSwizzler.swizzleAppDelegateMethods()
        
        if CordialApiConfiguration.shared.pushNotificationHandler != nil {
            self.cordialPushNotification.registerForPushNotifications()
        }
    }
}
