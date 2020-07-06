//
//  ContactsSenderHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ContactsSenderHelper {
    
    func prepareDataBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        
        self.removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: upsertContactRequests)
        
        self.preparingCacheForSubsequentAttemptsToMakeContactsUpsert(upsertContactRequests: upsertContactRequests)
        
        return self.removeUpsertContactRequestIfNotificationTokenNotPresented(upsertContactRequests: upsertContactRequests)
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
                if customEventRequests.count > 0 {
                    customEventRequests.forEach { customEventRequest in
                        if upsertContactRequest.primaryKey == customEventRequest.primaryKey {
                            CoreDataManager.shared.customEventRequests.putCustomEventRequestsToCoreData(sendCustomEventRequests: [customEventRequest])
                        }
                    }
                }
                
                // Cart
                if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData(), upsertContactRequest.primaryKey == upsertContactCartRequest.primaryKey {
                    CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                }
                
                // Orders
                let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
                if sendContactOrderRequests.count > 0 {
                    sendContactOrderRequests.forEach { sendContactOrderRequest in
                        if upsertContactRequest.primaryKey == sendContactOrderRequest.primaryKey {
                            CoreDataManager.shared.contactOrderRequests.setContactOrderRequestsToCoreData(sendContactOrderRequests: [sendContactOrderRequest])
                        }
                    }
                }
            }
        }
    }
    
    private func removeUpsertContactRequestIfNotificationTokenNotPresented(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        
        var upsertContactRequests = upsertContactRequests
        
        for index in 0...(upsertContactRequests.count - 1) {
            if upsertContactRequests[index].token == nil {
                upsertContactRequests.remove(at: index)
            }
        }
        
        return upsertContactRequests
    }
}
