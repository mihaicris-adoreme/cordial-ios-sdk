//
//  CordialPushNotificationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit

@objcMembers public class CordialPushNotificationHandler: NSObject {
    
    public func isCordialMessage(userInfo: [AnyHashable : Any]) -> Bool {
        if PushNotificationParser().getMcID(userInfo: userInfo) != nil {
            return true
        }
        
        return false
    }
    
    public func processNewPushNotificationToken(deviceToken: Data) {
        CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    public func processAppOpenViaPushNotificationTap(userInfo: [AnyHashable : Any], completionHandler: () -> Void) {
        if self.isCordialMessage(userInfo: userInfo) {
            PushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo, completionHandler: completionHandler)
        }
    }
    
    public func processNotificationDeliveryInForeground(userInfo: [AnyHashable : Any], completionHandler: (UNNotificationPresentationOptions) -> Void) {
        if self.isCordialMessage(userInfo: userInfo) {
            PushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo, completionHandler: completionHandler)
        }
    }
    
    public func processSilentPushDelivery(userInfo: [AnyHashable : Any]) {
        if self.isCordialMessage(userInfo: userInfo) {
            DispatchQueue.main.async {
                CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
            }
        }
    }
}
