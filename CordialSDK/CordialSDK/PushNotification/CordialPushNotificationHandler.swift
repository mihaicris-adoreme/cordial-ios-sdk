//
//  CordialPushNotificationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialPushNotificationHandler: NSObject {
    
    @objc public func isCordialMessage(userInfo: [AnyHashable : Any]) -> Bool {
        if CordialPushNotificationParser().getMcID(userInfo: userInfo) != nil {
            return true
        }
        
        return false
    }
    
    @objc public func processNewPushNotificationToken(deviceToken: Data) {
        CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    @objc public func processAppOpenViaPushNotificationTap(userInfo: [AnyHashable : Any], completionHandler: () -> Void) {
        CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    @objc public func processNotificationDeliveryInForeground(userInfo: [AnyHashable : Any], completionHandler: (UNNotificationPresentationOptions) -> Void) {
        CordialPushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    @objc public func processSilentPushDelivery(userInfo: [AnyHashable : Any]) {
        if self.isCordialMessage(userInfo: userInfo) {
            // TMP: For tests case purpose only
//            CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
        }
    }
}
