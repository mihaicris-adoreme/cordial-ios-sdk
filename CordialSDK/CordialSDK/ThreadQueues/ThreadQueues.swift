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
   
    let queueUpsertContact = DispatchQueue(label: "CordialCoreDataUpsertContactThreadQueue", attributes: .concurrent)
    let queueSendCustomEvent = DispatchQueue(label: "CordialCoreDataSendCustomEventThreadQueue", attributes: .concurrent)
    let queueUpsertContactCart = DispatchQueue(label: "CordialCoreDataUpsertContactCartThreadQueue", attributes: .concurrent)
    let queueSendContactOrder = DispatchQueue(label: "CordialCoreDataSendContactOrderThreadQueue", attributes: .concurrent)
    let queueFetchInAppMessages = DispatchQueue(label: "CordialCoreDataFetchInAppMessagesThreadQueue", attributes: .concurrent)
    let queueInboxMessagesMarkReadUnread = DispatchQueue(label: "CordialCoreDataInboxMessagesMarkReadUnreadThreadQueue", attributes: .concurrent)
    let queueInboxMessageDelete = DispatchQueue(label: "CordialCoreDataInboxMessageDeleteThreadQueue", attributes: .concurrent)
    let queueInboxMessagesCache = DispatchQueue(label: "CordialCoreDataInboxMessagesCacheThreadQueue", attributes: .concurrent)
    let queueInboxMessagesContent = DispatchQueue(label: "CordialCoreDataInboxMessagesContentThreadQueue", attributes: .concurrent)
    let queueSendContactLogout = DispatchQueue(label: "CordialCoreDataSendContactLogoutThreadQueue", attributes: .concurrent)
    
    
    private init() {}
    
}
