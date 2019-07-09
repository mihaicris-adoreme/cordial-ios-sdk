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
    
    static let cordialSendCustomEventsLogicError = Notification.Name("CordialSendCustomEventsLogicError")
    static let cordialUpsertContactCartLogicError = Notification.Name("CordialUpsertContactCartLogicError")
    static let cordialSendContactOrdersLogicError = Notification.Name("CordialSendContactOrdersLogicError")
    static let cordialUpsertContactsLogicError = Notification.Name("CordialUpsertContactsLogicError")
    static let cordialSendContactLogoutLogicError = Notification.Name("CordialSendContactLogoutLogicError")
    static let cordialFetchInAppMessageLogicError = Notification.Name("CordialFetchInAppMessageLogicErrorr")
    
}
