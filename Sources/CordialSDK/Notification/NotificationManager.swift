//
//  NotificationManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import UserNotifications

public extension Notification.Name {
    
    static let cordialConnectedToInternet = Notification.Name("CordialConnectedToInternet")
    static let cordialNotConnectedToInternet = Notification.Name("CordialNotConnectedToInternet")
        
    static let cordialSendCustomEventsLogicError = Notification.Name("CordialSDKSendCustomEventsLogicError")
    static let cordialUpsertContactCartLogicError = Notification.Name("CordialSDKUpsertContactCartLogicError")
    static let cordialSendContactOrdersLogicError = Notification.Name("CordialSDKSendContactOrdersLogicError")
    static let cordialUpsertContactsLogicError = Notification.Name("CordialSDKUpsertContactsLogicError")
    static let cordialSendContactLogoutLogicError = Notification.Name("CordialSDKSendContactLogoutLogicError")
    static let cordialInAppMessageLogicError = Notification.Name("CordialSDKInAppMessageLogicError")
    static let cordialInboxMessagesMarkReadUnreadLogicError = Notification.Name("CordialSDKInboxMessagesMarkReadUnreadLogicError")
    static let cordialInboxMessageDeleteRequestLogicError = Notification.Name("CordialSDKInboxMessageDeleteRequestLogicError")
}

@objc public extension NSNotification {
    static let cordialConnectedToInternet = Notification.Name.cordialConnectedToInternet
    static let cordialNotConnectedToInternet = Notification.Name.cordialNotConnectedToInternet
    
    static let cordialSendCustomEventsLogicError = Notification.Name.cordialSendCustomEventsLogicError
    static let cordialUpsertContactCartLogicError = Notification.Name.cordialUpsertContactCartLogicError
    static let cordialSendContactOrdersLogicError = Notification.Name.cordialSendContactOrdersLogicError
    static let cordialUpsertContactsLogicError = Notification.Name.cordialUpsertContactsLogicError
    static let cordialSendContactLogoutLogicError = Notification.Name.cordialSendContactLogoutLogicError
    static let cordialInAppMessageLogicError = Notification.Name.cordialInAppMessageLogicError
    static let cordialInboxMessagesMarkReadUnreadLogicError = Notification.Name.cordialInboxMessagesMarkReadUnreadLogicError
    static let cordialInboxMessageDeleteRequestLogicError = Notification.Name.cordialInboxMessageDeleteRequestLogicError
}

class NotificationManager {
    
    static let shared = NotificationManager()
    
    var vanityDeepLink = String()
    var originDeepLink = String()
    
    var appMovedToBackgroundBackgroundTaskID: UIBackgroundTaskIdentifier?

    private init() {}
    
    @objc func appMovedToBackground() {
        self.appMovedToBackgroundBackgroundTaskID = UIApplication.shared.beginBackgroundTask(expirationHandler: { [weak self] in
            guard let backgroundTaskID = self?.appMovedToBackgroundBackgroundTaskID else { return }
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
        })
        
        ThrottlerManager.shared.appMovedToBackground.throttle {
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
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func appMovedFromBackground() {
        ThrottlerManager.shared.appMovedFromBackground.throttle {
            self.appMovedFromBackgroundProceed()
        }
    }
    
    func appMovedFromBackgroundProceed() {
        let eventName = API.EVENT_NAME_APP_MOVED_FROM_BACKGROUND
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
        PushNotificationHelper().prepareCurrentPushNotificationStatus()
        
        CordialLocationManager.shared.updateLocationAuthorizationStatus()
        
        // IAM
        InAppMessagesQueueManager().fetchInAppMessageDataFromQueue()
              
        // IAMs
        InAppMessagesGetter().startFetchInAppMessages(isSilentPushDeliveryEvent: false)
        
        // IAM show
        InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
        
        if let vanityDeepLinkURL = URL(string: self.vanityDeepLink) {
            CordialVanityDeepLink().open(url: vanityDeepLinkURL)
        }
    }
        
    func setupNotificationManager() {
        let notificationCenter = NotificationCenter.default
        
        if #available(iOS 13.0, *), InternalCordialAPI().isAppUseScenes() {
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
        
        DispatchQueue.main.async {
            CordialSwizzler.shared.swizzleAppAndSceneDelegateMethods()
            
            CordialPushNotification.shared.registerForSilentPushNotifications()
        }
    }

}
