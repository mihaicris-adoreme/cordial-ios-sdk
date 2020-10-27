//
//  ThrottlerManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 27.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ThrottlerManager {
    
    static let shared = ThrottlerManager()
    
    private init(){}
    
    let upsertContactRequest = Throttler(minimumDelay: 1, queue: ThreadQueues.shared.queueUpsertContactRequest, flags: .barrier)
    let sendCustomEventRequest = Throttler(minimumDelay: 1, queue: DispatchQueue.main)
    let upsertContactCartRequest = Throttler(minimumDelay: 1, queue: ThreadQueues.shared.queueUpsertContactCartRequest, flags: .barrier)
    let sendContactOrderRequest = Throttler(minimumDelay: 1, queue: ThreadQueues.shared.queueSendContactOrderRequest, flags: .barrier)
    let fetchInAppMessages = Throttler(minimumDelay: 1, queue: ThreadQueues.shared.queueFetchInAppMessages, flags: .barrier)
    let sendContactLogoutRequest = Throttler(minimumDelay: 1, queue: ThreadQueues.shared.queueSendContactLogoutRequest, flags: .barrier)
    
}
