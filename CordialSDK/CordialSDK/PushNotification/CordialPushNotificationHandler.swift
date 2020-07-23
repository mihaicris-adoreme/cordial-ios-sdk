//
//  CordialPushNotificationHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class CordialPushNotificationHandler {
    
    func isCordialMessage(userInfo: [AnyHashable : Any]) {
        
    }
    
    func processNewPushNotificationToken(deviceToken: Data) {
        CordialSwizzlerHelper().didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    
    func processAppOpenViaPushNotificationTap(userInfo: [AnyHashable : Any]) {
        CordialPushNotificationHelper().pushNotificationHasBeenTapped(userInfo: userInfo)
    }
    
    func processNotificationDeliveryInForeground(userInfo: [AnyHashable : Any]) {
        CordialPushNotificationHelper().pushNotificationHasBeenForegroundDelivered(userInfo: userInfo)
    }
    
    func processSilentPushDelivery(userInfo: [AnyHashable : Any]) {
        CordialSwizzlerHelper().didReceiveRemoteNotification(userInfo: userInfo)
    }
}
