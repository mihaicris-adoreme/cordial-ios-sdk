//
//  CoreDataSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

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
            InAppMessagesQueueManager().fetchInAppMessageDataFromQueue()
            
            // Contact Timestamps
            ContactTimestamps.shared.updateIfNeeded()
        }
        
        self.sendCachedContactLogoutRequest()
    }
    
    private func sendCachedUpsertContactRequests() {
        let upsertContactRequests = CoreDataManager.shared.contactRequests.fetchContactRequests()
        if !upsertContactRequests.isEmpty {
            ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
        }
    }
    
    func sendCachedCustomEventRequests(reason: String) {
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() && !internalCordialAPI.isCurrentlyUpsertingContacts() {
            let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequests()
            
            if customEventRequests.count > 0 {
                if CordialApiConfiguration.shared.eventsBulkSize != 1 {
                    LoggerManager.shared.info(message: "Flushing events. Reason: [\(reason)]", category: "CordialSDKSendCustomEvents")
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
        if InternalCordialAPI().isUserLogin() {
            if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.fetchContactCartRequest() {
                ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
            }
        }
    }
    
    private func sendCachedContactOrderRequests() {
        if InternalCordialAPI().isUserLogin() {
            let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.fetchContactOrderRequests()
            if !sendContactOrderRequests.isEmpty {
                ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
            }
        }
    }
    
    private func sendCachedInboxMessagesMarkReadUnreadRequests() {
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
        if InternalCordialAPI().isUserLogin() {
            let inboxMessageDeleteRequests = CoreDataManager.shared.inboxMessageDelete.fetchInboxMessageDeleteRequestsFromCoreData()
            inboxMessageDeleteRequests.forEach { inboxMessageDeleteRequest in
                InboxMessageDeleteSender().sendInboxMessageDelete(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            }
        }
    }
    
    private func sendCachedContactLogoutRequest() {
        if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.fetchContactLogoutRequest() {
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
        }
    }
}
