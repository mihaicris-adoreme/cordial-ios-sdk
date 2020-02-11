//
//  CordialPushNotificationHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class CordialPushNotificationHandler: CordialPushNotificationDelegate {
    
    func appOpenViaNotificationTap(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func notificationDeliveredInForeground(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func apnsTokenReceived(token: String) {
        
    }
}
