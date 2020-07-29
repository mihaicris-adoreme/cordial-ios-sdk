//
//  CordialPushNotificationDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/2/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol CordialPushNotificationDelegate {
    
    @objc func appOpenViaNotificationTap(notificationContent: [AnyHashable : Any])
    @objc func notificationDeliveredInForeground(notificationContent: [AnyHashable : Any])
    @objc func apnsTokenReceived(token: String)
    
}
