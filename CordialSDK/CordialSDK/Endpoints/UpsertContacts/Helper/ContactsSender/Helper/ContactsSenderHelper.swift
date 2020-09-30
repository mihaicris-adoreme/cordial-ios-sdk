//
//  ContactsSenderHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ContactsSenderHelper {
    
    func prepareCoreDataCacheBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) {
        
        self.removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: upsertContactRequests)
        
        self.preparingCacheForSubsequentAttemptsToMakeContactsUpsert(upsertContactRequests: upsertContactRequests)
    }
    
    private func removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: [UpsertContactRequest]) {
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            let previousPrimaryKey = internalCordialAPI.getPreviousContactPrimaryKey()
            
            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey && previousPrimaryKey != nil {
                    internalCordialAPI.removeAllCachedData()
                    internalCordialAPI.removePreviousContactPrimaryKey()
                }
            }
        }
    }
    
    private func preparingCacheForSubsequentAttemptsToMakeContactsUpsert(upsertContactRequests: [UpsertContactRequest]) {
        if InternalCordialAPI().isCurrentlyUpsertingContacts() {
            // Save client data if primary keys the same
            upsertContactRequests.forEach { upsertContactRequest in
                // Events
                let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
                customEventRequests.forEach { customEventRequest in
                    if upsertContactRequest.primaryKey == customEventRequest.primaryKey {
                        CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: [customEventRequest])
                    }
                }
                
                // Cart
                if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData(),
                   upsertContactRequest.primaryKey == upsertContactCartRequest.primaryKey {
                    CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                }
                
                // Orders
                let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
                sendContactOrderRequests.forEach { sendContactOrderRequest in
                    if upsertContactRequest.primaryKey == sendContactOrderRequest.primaryKey {
                        CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: [sendContactOrderRequest])
                    }
                }
                
                // Inbox message read/unread marks
                let inboxMessagesMarkReadUnreadRequests = CoreDataManager.shared.inboxMessagesMarkReadUnread.fetchInboxMessagesMarkReadUnreadDataFromCoreData()
                inboxMessagesMarkReadUnreadRequests.forEach { inboxMessagesMarkReadUnreadRequest in
                    if upsertContactRequest.primaryKey == inboxMessagesMarkReadUnreadRequest.primaryKey {
                        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
                    }
                }
                 
                // Inbox message delete
                let inboxMessageDeleteRequests = CoreDataManager.shared.inboxMessageDelete.fetchInboxMessageDeleteRequestsFromCoreData()
                inboxMessageDeleteRequests.forEach { inboxMessageDeleteRequest in
                    if upsertContactRequest.primaryKey == inboxMessageDeleteRequest.primaryKey {
                        CoreDataManager.shared.inboxMessageDelete.putInboxMessageDeleteRequestToCoreData(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
                    }
                }
            }
        }
    }
    
}
