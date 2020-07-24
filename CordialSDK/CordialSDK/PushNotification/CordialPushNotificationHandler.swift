//
//  CordialPushNotificationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialPushNotificationHandler: NSObject {
    
    private let swizzlerHelper = CordialSwizzlerHelper()
    private let pushNotificationHelper = CordialPushNotificationHelper()
    
    @objc public func isCordialMessage(userInfo: [AnyHashable : Any]) {
        
    }
    
    @objc public func processNewPushNotificationToken(deviceToken: Data) {
        self.swizzlerHelper.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    @objc public func processAppOpenViaPushNotificationTap(userInfo: [AnyHashable : Any], completionHandler: () -> Void) {
        self.pushNotificationHelper.pushNotificationHasBeenTapped(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    @objc public func processNotificationDeliveryInForeground(userInfo: [AnyHashable : Any], completionHandler: (UNNotificationPresentationOptions) -> Void) {
        self.pushNotificationHelper.pushNotificationHasBeenForegroundDelivered(userInfo: userInfo, completionHandler: completionHandler)
    }
    
    @objc public func processSilentPushDelivery(userInfo: [AnyHashable : Any]) {
        self.swizzlerHelper.didReceiveRemoteNotification(userInfo: userInfo)
    }
}
