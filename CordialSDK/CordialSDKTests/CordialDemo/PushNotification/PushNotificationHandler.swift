//
//  PushNotificationHandler.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 04.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class PushNotificationHandler: CordialPushNotificationDelegate {
    
    func appOpenViaNotificationTap(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func notificationDeliveredInForeground(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func apnsTokenReceived(token: String) {
        
    }
}
