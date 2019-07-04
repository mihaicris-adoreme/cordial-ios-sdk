//
//  Notification.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/9/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public extension Notification.Name {
    
    static let connectedToInternet = Notification.Name("ConnectedToInternet")
    static let notConnectedToInternet = Notification.Name("NotConnectedToInternet")
    
    static let sendCustomEventsLogicError = Notification.Name("SendCustomEventsLogicError")
    static let upsertContactCartLogicError = Notification.Name("UpsertContactCartLogicError")
    static let sendContactOrdersLogicError = Notification.Name("SendContactOrdersLogicError")
    static let upsertContactsLogicError = Notification.Name("UpsertContactsLogicError")
    static let sendContactLogoutLogicError = Notification.Name("SendContactLogoutLogicError")
    static let fetchInAppMessageLogicError = Notification.Name("FetchInAppMessageLogicError")
    
}
