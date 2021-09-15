//
//  CordialSwiftUIPushNotificationPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.07.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIPushNotificationPublisher: ObservableObject {
    
    public static let shared = CordialSwiftUIPushNotificationPublisher()

    private init() {}
    
    public let appOpenViaNotificationTap = PassthroughSubject<CordialSwiftUIPushNotificationAppOpenViaNotificationTap, Never>()
    public let notificationDeliveredInForeground = PassthroughSubject<CordialSwiftUIPushNotificationDeliveredInForeground, Never>()
    public let apnsTokenReceived = PassthroughSubject<CordialSwiftUIPushNotificationApnsTokenReceived, Never>()
    
    func publishAppOpenViaNotificationTap(notificationContent: [AnyHashable : Any]) {
        let appOpenViaNotificationTap = CordialSwiftUIPushNotificationAppOpenViaNotificationTap(notificationContent: notificationContent)
        
        self.appOpenViaNotificationTap.send(appOpenViaNotificationTap)
    }
    
    func publishNotificationDeliveredInForeground(notificationContent: [AnyHashable : Any]) {
        let notificationDeliveredInForeground = CordialSwiftUIPushNotificationDeliveredInForeground(notificationContent: notificationContent)
        
        self.notificationDeliveredInForeground.send(notificationDeliveredInForeground)
    }
    
    func publishApnsTokenReceived(token: String) {
        let apnsTokenReceived = CordialSwiftUIPushNotificationApnsTokenReceived(token: token)
        
        self.apnsTokenReceived.send(apnsTokenReceived)
    }
    
}
