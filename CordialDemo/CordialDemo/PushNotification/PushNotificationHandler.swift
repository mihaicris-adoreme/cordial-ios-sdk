//
//  PushNotificationHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class PushNotificationHandler: CordialPushNotificationDelegate {
    
    func appOpenViaNotificationTap(notificationContent: [AnyHashable : Any]) {

    }
    
    func notificationDeliveredInForeground(notificationContent: [AnyHashable : Any]) {
        
    }

    func apnsTokenReceived(token: String) {
        
    }
}
