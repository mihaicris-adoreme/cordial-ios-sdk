//
//  AppNotificationManager.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 28.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications
import CordialSDK

public extension Notification.Name {
    static let cordialDemoNewInboxMessageDelivered = Notification.Name("CordialDemoNewInboxMessageDelivered")
}

class AppNotificationManager {
    
    static let shared = AppNotificationManager()
    
    func setupCordialSDKLogicErrorHandler() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .cordialSendCustomEventsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendCustomEventsLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialUpsertContactCartLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialUpsertContactCartLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialSendContactOrdersLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendContactOrdersLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialUpsertContactsLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialUpsertContactsLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialSendContactLogoutLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialSendContactLogoutLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInAppMessageLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInAppMessageLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInboxMessagesMarkReadUnreadLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInboxMessagesMarkReadUnreadLogicError, object: nil)
        
        notificationCenter.removeObserver(self, name: .cordialInboxMessageDeleteRequestLogicError, object: nil)
        notificationCenter.addObserver(self, selector: #selector(cordialNotificationErrorHandler(notification:)), name: .cordialInboxMessageDeleteRequestLogicError, object: nil)
        
    }
    
    @objc func cordialNotificationErrorHandler(notification: NSNotification) {
        if let error = notification.object as? ResponseError {
            CordialAPI().showSystemAlert(title: error.message, message: error.responseBody)
        }
    }
        
}
