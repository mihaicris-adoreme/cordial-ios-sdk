//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class CordialApiConfiguration {
    
    public static let shared = CordialApiConfiguration()
    
    let reachabilityManager = ReachabilityManager.shared
    let reachabilitySender = ReachabilitySender.shared
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    public var pushNotificationHandler: CordialPushNotificationDelegate?
    let cordialPushNotification = CordialPushNotification()
    let cordialPushNotificationSwizzler = CordialPushNotificationSwizzler()
    
    private init(){}
    
    public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.skrivobocheck.cordialdev.com/"
        
//        CoreDataManager.shared.deleteAllCoreData()
        
        self.prepareDeviceIdentifier()
        
        let cordialAPI = CordialAPI()
        
        let firstLaunch = CordialFirstLaunch(userDefaults: .standard, key: API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH)
        if firstLaunch.isFirstLaunch {
            let eventName = API.USER_DEFAULTS_KEY_FOR_FIRST_LAUNCH_EVENT_NAME
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
            cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
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
        let cordialAPI = CordialAPI()
        
        let eventName = API.USER_DEFAULTS_KEY_FOR_APP_MOVED_TO_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func appMovedFromBackground() {
        let cordialAPI =  CordialAPI()
        
        let eventName = API.USER_DEFAULTS_KEY_FOR_APP_MOVED_FROM_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func handleAppDidFinishLaunchingNotification(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        print(notification)
        
        // Setup Push Notification
        cordialPushNotification.registerForPushNotifications()
        cordialPushNotificationSwizzler.swizzleAppDelegateMethods()
    }
}
