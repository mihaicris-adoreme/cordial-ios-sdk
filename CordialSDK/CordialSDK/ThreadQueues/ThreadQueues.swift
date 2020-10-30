//
//  ThreadQueues.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ThreadQueues {
    
    static let shared = ThreadQueues()
   
    let queueUpsertContactRequest = DispatchQueue(label: "CordialCoreDataSenderUpsertContactRequestThreadQueue", attributes: .concurrent)
    let queueSendCustomEventRequest = DispatchQueue(label: "CordialCoreDataSenderSendCustomEventRequestThreadQueue", attributes: .concurrent)
    let queueUpsertContactCartRequest = DispatchQueue(label: "CordialCoreDataSenderUpsertContactCartRequestThreadQueue", attributes: .concurrent)
    let queueSendContactOrderRequest = DispatchQueue(label: "CordialCoreDataSenderSendContactOrderRequestThreadQueue", attributes: .concurrent)
    let queueFetchInAppMessages = DispatchQueue(label: "CordialInAppMessagesQueueManagerFetchInAppMessagesThreadQueue", attributes: .concurrent)
    let queueInboxMessagesMarkReadUnreadRequest = DispatchQueue(label: "CordialCoreDataSenderInboxMessagesMarkReadUnreadRequestThreadQueue", attributes: .concurrent)
    let queueInboxMessageDeleteRequest = DispatchQueue(label: "CordialCoreDataSenderInboxMessageDeleteRequestThreadQueue", attributes: .concurrent)
    let queueSendContactLogoutRequest = DispatchQueue(label: "CordialCoreDataSenderSendContactLogoutRequestThreadQueue", attributes: .concurrent)
    
    private init() {}
    
}
