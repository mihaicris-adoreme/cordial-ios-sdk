//
//  NotificationManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications

public extension Notification.Name {
    
    static let connectedToInternet = Notification.Name("ConnectedToInternet")
    static let notConnectedToInternet = Notification.Name("NotConnectedToInternet")
    
    static let cordialConnectionSettingsHasBeenChange = Notification.Name("CordialConnectionSettingsHasBeenChange")
    
    static let cordialSendCustomEventsLogicError = Notification.Name("CordialSendCustomEventsLogicError")
    static let cordialUpsertContactCartLogicError = Notification.Name("CordialUpsertContactCartLogicError")
    static let cordialSendContactOrdersLogicError = Notification.Name("CordialSendContactOrdersLogicError")
    static let cordialUpsertContactsLogicError = Notification.Name("CordialUpsertContactsLogicError")
    static let cordialSendContactLogoutLogicError = Notification.Name("CordialSendContactLogoutLogicError")
    static let cordialInAppMessageLogicError = Notification.Name("CordialInAppMessageLogicError")
    
}

@objc public extension NSNotification {
    static let connectedToInternet = Notification.Name.connectedToInternet
    static let notConnectedToInternet = Notification.Name.notConnectedToInternet
    
    static let cordialConnectionSettingsHasBeenChange = Notification.Name.cordialConnectionSettingsHasBeenChange
    
    static let cordialSendCustomEventsLogicError = Notification.Name.cordialSendCustomEventsLogicError
    static let cordialUpsertContactCartLogicError = Notification.Name.cordialUpsertContactCartLogicError
    static let cordialSendContactOrdersLogicError = Notification.Name.cordialSendContactOrdersLogicError
    static let cordialUpsertContactsLogicError = Notification.Name.cordialUpsertContactsLogicError
    static let cordialSendContactLogoutLogicError = Notification.Name.cordialSendContactLogoutLogicError
    static let cordialInAppMessageLogicError = Notification.Name.cordialInAppMessageLogicError
}

class NotificationManager {
    
    static let shared = NotificationManager()
    
    var isNotificationManagerHasNotBeenSettedUp = true
    
    let appMovedToBackgroundThrottler = Throttler(minimumDelay: 1)
    var appMovedToBackgroundBackgroundTaskID: UIBackgroundTaskIdentifier?
    
    let appMovedFromBackgroundThrottler = Throttler(minimumDelay: 1)

    private init() {
        let notificationCenter = NotificationCenter.default
        
        if self.isNotificationManagerHasNotBeenSettedUp {
            self.isNotificationManagerHasNotBeenSettedUp = false
            
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(handleDidFinishLaunch), name: UIApplication.didBecomeActiveNotification, object: nil)
        } 
    }
    
    @objc func appMovedToBackground() {
        self.appMovedToBackgroundBackgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let backgroundTaskID = self?.appMovedToBackgroundBackgroundTaskID else { return }
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
        })
        
        self.appMovedToBackgroundThrottler.throttle {
            self.appMovedToBackgroundProceed()
            
            if let backgroundTaskID = self.appMovedToBackgroundBackgroundTaskID {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                self.appMovedToBackgroundBackgroundTaskID = nil
            }
        }
    }
    
    func appMovedToBackgroundProceed() {
        let eventName = API.EVENT_NAME_APP_MOVED_TO_BACKGROUND
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        CoreDataManager.shared.coreDataSender.sendCachedCustomEventRequests(reason: "App moved to background")
    }
    
    @objc func appMovedFromBackground() {
        self.appMovedFromBackgroundThrottler.throttle {
            self.appMovedFromBackgroundProceed()
        }
    }
    
    func appMovedFromBackgroundProceed() {
        let eventName = API.EVENT_NAME_APP_MOVED_FROM_BACKGROUND
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: nil)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.prepareCurrentPushNotificationStatus()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
        InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
    }
    
    @objc func connectionSettingsHasBeenChangeHandler() {
        InternalCordialAPI().removeCurrentMcID()
    }
    
    private func prepareCurrentPushNotificationStatus() {
        DispatchQueue.main.async {
            let current = UNUserNotificationCenter.current()
            
            current.getNotificationSettings(completionHandler: { (settings) in
                let internalCordialAPI = InternalCordialAPI()
                
                let token = internalCordialAPI.getPushNotificationToken()
                let primaryKey = CordialAPI().getContactPrimaryKey()
                
                if settings.authorizationStatus == .authorized {
                    if API.PUSH_NOTIFICATION_STATUS_ALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) {
                        let status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                        
                        let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
                        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
                        
                        internalCordialAPI.setPushNotificationStatus(status: status)
                    }
                } else {
                    if API.PUSH_NOTIFICATION_STATUS_DISALLOW != CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_PUSH_NOTIFICATION_STATUS) {
                        let status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                        
                        let upsertContactRequest = UpsertContactRequest(token: token, primaryKey: primaryKey, status: status, attributes: nil)
                        ContactsSender().upsertContacts(upsertContactRequests: [upsertContactRequest])
                        
                        internalCordialAPI.setPushNotificationStatus(status: status)
                    }
                }
            })
        }
    }
    
    @objc func handleDidFinishLaunch(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        
        let notificationCenter = NotificationCenter.default
        
        if !self.isNotificationManagerHasNotBeenSettedUp {
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            
            self.appMovedFromBackground()
        }
        
        if #available(iOS 13.0, *), InternalCordialAPI().doesAppUseScenes() {
            notificationCenter.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
            
            notificationCenter.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
            
            notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
            notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        
        notificationCenter.removeObserver(self, name: .cordialConnectionSettingsHasBeenChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(connectionSettingsHasBeenChangeHandler), name: .cordialConnectionSettingsHasBeenChange, object: nil)
        
        CordialApiConfiguration.shared.cordialSwizzler.swizzleAppDelegateMethods()
    }

}
