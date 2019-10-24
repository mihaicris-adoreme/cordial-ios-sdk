//
//  CoreDataSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CoreDataSender {
    
    // MARK: Send cache from CoreData
    
    func sendCacheFromCoreData() {
        self.sendCachedCustomEventRequests()
        
        self.sendCachedUpsertContactCartRequest()
        
        self.sendCachedContactOrderRequests()
        
        self.sendCachedUpsertContactRequests()
        
        self.sendCachedContactLogoutRequest()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
    func sendCachedCustomEventRequests() {
        let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
        if customEventRequests.count > 0 {
            CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
        }
    }
    
    func sendCachedCustomEventRequestsScheduledTimer() {
        Timer.scheduledTimer(withTimeInterval: CordialApiConfiguration.shared.timeCachedEventsBox, repeats: true) { timer in
            self.sendCachedCustomEventRequests()
        }
    }
    
    private func sendCachedUpsertContactCartRequest() {
        if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData() {
            ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
        }
    }
    
    private func sendCachedContactOrderRequests() {
        let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
        if sendContactOrderRequests.count > 0 {
            ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
        }
    }
    
    private func sendCachedUpsertContactRequests() {
        let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
        if upsertContactRequests.count > 0 {
            ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
        }
    }
    
    private func sendCachedContactLogoutRequest() {
        if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.getContactLogoutRequestFromCoreData() {
            ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
        }
    }
}
