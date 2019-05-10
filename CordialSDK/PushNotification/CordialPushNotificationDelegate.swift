//
//  CordialPushNotificationDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public protocol CordialPushNotificationDelegate {
    
    func appOpenViaNotificationTap(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    func notificationDeliveredInForeground(notificationContent: [AnyHashable : Any], completionHandler: @escaping () -> Void)
    
}
