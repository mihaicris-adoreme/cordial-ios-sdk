//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications

@objc public class CordialApiConfiguration: NSObject {
    
    @objc public static let shared = CordialApiConfiguration()
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    
    @objc public var qtyCachedEventQueue = 1000
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    let cordialSwizzler = CordialSwizzler()
    
    @objc public var continueRestorationHandler: CordialContinueRestorationDelegate?
    @objc public var openOptionsHandler: CordialOpenOptionsDelegate?
    @objc public var pushNotificationHandler: CordialPushNotificationDelegate?
    
    let cordialPushNotification = CordialPushNotification()
    
    private override init(){}
    
    @objc public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.cordial.com/"
        
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
    
    @objc func handleAppDidFinishLaunchingNotification(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        print(notification)
        
        self.cordialSwizzler.swizzleAppDelegateMethods()
        
        self.cordialPushNotification.getNotificationSettings()
    }
}
