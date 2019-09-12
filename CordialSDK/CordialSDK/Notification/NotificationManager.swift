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
    
    static let cordialSendCustomEventsLogicError = Notification.Name("CordialSendCustomEventsLogicError")
    static let cordialUpsertContactCartLogicError = Notification.Name("CordialUpsertContactCartLogicError")
    static let cordialSendContactOrdersLogicError = Notification.Name("CordialSendContactOrdersLogicError")
    static let cordialUpsertContactsLogicError = Notification.Name("CordialUpsertContactsLogicError")
    static let cordialSendContactLogoutLogicError = Notification.Name("CordialSendContactLogoutLogicError")
    static let cordialInAppMessageLogicError = Notification.Name("CordialInAppMessageLogicErrorr")
    
}

@objc public extension NSNotification {
    static let connectedToInternet = Notification.Name.connectedToInternet
    static let notConnectedToInternet = Notification.Name.notConnectedToInternet
    
    static let cordialSendCustomEventsLogicError = Notification.Name.cordialSendCustomEventsLogicError
    static let cordialUpsertContactCartLogicError = Notification.Name.cordialUpsertContactCartLogicError
    static let cordialSendContactOrdersLogicError = Notification.Name.cordialSendContactOrdersLogicError
    static let cordialUpsertContactsLogicError = Notification.Name.cordialUpsertContactsLogicError
    static let cordialSendContactLogoutLogicError = Notification.Name.cordialSendContactLogoutLogicError
}

class NotificationManager {
    
    static let shared = NotificationManager()

    private init() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: UIApplication.didFinishLaunchingNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleAppDidFinishLaunchingNotification), name: UIApplication.didFinishLaunchingNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        let eventName = API.EVENT_NAME_APP_MOVED_TO_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func appMovedFromBackground() {
        let eventName = API.EVENT_NAME_APP_MOVED_FROM_BACKGROUND
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: nil)
        CordialAPI().sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        self.prepareCurrentPushNotificationStatus()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
        InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
    }
    
    private func prepareCurrentPushNotificationStatus() {
        DispatchQueue.main.async {
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
    }
    
    @objc func handleAppDidFinishLaunchingNotification(notification: NSNotification) {
        // This code will be called immediately after application:didFinishLaunchingWithOptions:
        
        CordialApiConfiguration.shared.cordialSwizzler.swizzleAppDelegateMethods()
        
        CordialApiConfiguration.shared.cordialPushNotification.getNotificationSettings()
    }

}
