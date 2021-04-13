//
//  CoreDataSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CoreDataSender {
    
    var canBeStartedCachedEventsScheduledTimer = true
    
    var sendCachedCustomEventsScheduledTimer: Timer?
    
    func sendCacheFromCoreData() {
        
        self.sendCachedUpsertContactRequests()
        
        if !InternalCordialAPI().isCurrentlyUpsertingContacts() {
            
            ThrottlerManager.shared.sendCustomEventRequest.throttle {
                self.sendCachedCustomEventRequests(reason: "System sending all cached events")
            }
            
            self.sendCachedUpsertContactCartRequest()
            
            self.sendCachedContactOrderRequests()
            
            self.sendCachedInboxMessagesMarkReadUnreadRequests()
            
            self.sendCachedInboxMessageDeleteRequests()
            
            // IAM
            ThreadQueues.shared.queueFetchInAppMessages.sync(flags: .barrier) {
                InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
            }
            
            // Contact Timestamps
            ContactTimestamps.shared.updateIfNeeded()
            
            // Contact Timestamp URL
            ContactTimestampURL.shared.updateIfNeeded(nil)
        }
        
        self.sendCachedContactLogoutRequest()
    }
    
    func sendCachedUpsertContactRequests() {
        ThreadQueues.shared.queueUpsertContact.sync(flags: .barrier) {
            let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
            if !upsertContactRequests.isEmpty {
                ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
            }
        }
    }
    
    func sendCachedCustomEventRequests(reason: String) {
        if InternalCordialAPI().isUserLogin() && !InternalCordialAPI().isCurrentlyUpsertingContacts() {
            let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
            if customEventRequests.count > 0 {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    if CordialApiConfiguration.shared.eventsBulkSize != 1 {
                        os_log("Flushing events blunk. Reason: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, reason)
                    }
                }
                
                CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
                
                self.restartSendCachedCustomEventRequestsScheduledTimer()
            }
        }
    }
    
    private func restartSendCachedCustomEventRequestsScheduledTimer() {
        self.canBeStartedCachedEventsScheduledTimer = true
        self.startSendCachedCustomEventRequestsScheduledTimer()
    }
    
    func startSendCachedCustomEventRequestsScheduledTimer() {
        let eventsBulkSize = CordialApiConfiguration.shared.eventsBulkSize
        if eventsBulkSize < 1 {
            CordialApiConfiguration.shared.eventsBulkSize = 1
        }
        
        let eventsBulkUploadInterval = CordialApiConfiguration.shared.eventsBulkUploadInterval
        if eventsBulkUploadInterval < 3 {
            CordialApiConfiguration.shared.eventsBulkUploadInterval = 3
        }
        
        if self.canBeStartedCachedEventsScheduledTimer {
            self.canBeStartedCachedEventsScheduledTimer = false
            self.sendCachedCustomEventsScheduledTimer?.invalidate()
            
            if eventsBulkSize > 1 {
                self.sendCachedCustomEventsScheduledTimer = Timer.scheduledTimer(withTimeInterval: eventsBulkUploadInterval, repeats: true) { timer in
                    
                    ThrottlerManager.shared.sendCustomEventRequest.throttle {
                        self.sendCachedCustomEventRequests(reason: "Scheduled timer")
                    }
                }
            } 
        }
    }
    
    private func sendCachedUpsertContactCartRequest() {
        ThreadQueues.shared.queueUpsertContactCart.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData() {
                    ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
                }
            }
        }
    }
    
    private func sendCachedContactOrderRequests() {
        ThreadQueues.shared.queueSendContactOrder.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
                if !sendContactOrderRequests.isEmpty {
                    ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
                }
            }
        }
    }
    
    private func sendCachedInboxMessagesMarkReadUnreadRequests() {
        ThreadQueues.shared.queueInboxMessagesMarkReadUnread.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                var inboxMessagesMarkReadUnreadRequestsWithPrimaryKey = [InboxMessagesMarkReadUnreadRequest]()
                var inboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey = [InboxMessagesMarkReadUnreadRequest]()
                
                let inboxMessagesMarkReadUnreadRequests = CoreDataManager.shared.inboxMessagesMarkReadUnread.fetchInboxMessagesMarkReadUnreadDataFromCoreData()
                inboxMessagesMarkReadUnreadRequests.forEach { inboxMessagesMarkReadUnreadRequest in
                    if inboxMessagesMarkReadUnreadRequest.primaryKey == CordialAPI().getContactPrimaryKey() {
                        inboxMessagesMarkReadUnreadRequestsWithPrimaryKey.append(inboxMessagesMarkReadUnreadRequest)
                    } else if inboxMessagesMarkReadUnreadRequest.primaryKey == InternalCordialAPI().getContactKey() {
                        inboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey.append(inboxMessagesMarkReadUnreadRequest)
                    }
                }
                
                if let firstInboxMessagesMarkReadUnreadRequestsWithPrimaryKey = inboxMessagesMarkReadUnreadRequestsWithPrimaryKey.first {
                    let mergedInboxMessagesMarkReadUnreadRequest = self.getInboxMessagesMarkReadUnreadRequest(primaryKey: firstInboxMessagesMarkReadUnreadRequestsWithPrimaryKey.primaryKey, inboxMessagesMarkReadUnreadRequests: inboxMessagesMarkReadUnreadRequestsWithPrimaryKey)
                    
                    InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: mergedInboxMessagesMarkReadUnreadRequest)
                }
                
                if let firstInboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey = inboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey.first {
                    let mergedInboxMessagesMarkReadUnreadRequest = self.getInboxMessagesMarkReadUnreadRequest(primaryKey: firstInboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey.primaryKey, inboxMessagesMarkReadUnreadRequests: inboxMessagesMarkReadUnreadRequestsWithoutPrimaryKey)
                    
                    InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: mergedInboxMessagesMarkReadUnreadRequest)
                }
            }
        }
    }
    
    private func getInboxMessagesMarkReadUnreadRequest(primaryKey: String?, inboxMessagesMarkReadUnreadRequests: [InboxMessagesMarkReadUnreadRequest]) -> InboxMessagesMarkReadUnreadRequest {
        
        var mergedMarkAsReadMcIDs = [String]()
        var mergedMarkAsUnreadMcIDs = [String]()
        
        inboxMessagesMarkReadUnreadRequests.forEach { inboxMessagesMarkReadUnreadRequest in
            inboxMessagesMarkReadUnreadRequest.markAsReadMcIDs.forEach { markAsReadMcID in
                if !mergedMarkAsReadMcIDs.contains(markAsReadMcID) {
                    mergedMarkAsReadMcIDs.append(markAsReadMcID)
                }
            }
            inboxMessagesMarkReadUnreadRequest.markAsUnreadMcIDs.forEach { markAsUnreadMcID in
                if !mergedMarkAsUnreadMcIDs.contains(markAsUnreadMcID) {
                    mergedMarkAsUnreadMcIDs.append(markAsUnreadMcID)
                }
            }
        }
        
        return InboxMessagesMarkReadUnreadRequest(requestID: UUID().uuidString, primaryKey: primaryKey, markAsReadMcIDs: mergedMarkAsReadMcIDs, markAsUnreadMcIDs: mergedMarkAsUnreadMcIDs, date: Date())
    }
    
    private func sendCachedInboxMessageDeleteRequests() {
        ThreadQueues.shared.queueInboxMessageDelete.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                let inboxMessageDeleteRequests = CoreDataManager.shared.inboxMessageDelete.fetchInboxMessageDeleteRequestsFromCoreData()
                inboxMessageDeleteRequests.forEach { inboxMessageDeleteRequest in
                    InboxMessageDeleteSender().sendInboxMessageDelete(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
                }
            }
        }
    }
    
    private func sendCachedContactLogoutRequest() {
        ThreadQueues.shared.queueSendContactLogout.sync(flags: .barrier) {
            if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.getContactLogoutRequestFromCoreData() {
                ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            }
        }
    }
}
