//
//  CarouselNotificationExtension.swift
//  NotificationContentExtension
//
//  Created by Yan Malinovsky on 21.03.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

struct CarouselNotificationExtension {
    
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINKS"
    static let USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID = "USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_CONTENT_EXTENSION_CAROUSEL_DEEP_LINK_ID"
    
}

extension Notification.Name {
    
    static let didReceiveCarouselsNotification = Notification.Name("CordialDidReceiveCarouselsNotification")
    
}
