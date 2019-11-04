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
    
    // MARK: Send cache from CoreData
    
    func sendCacheFromCoreData() {
        self.sendCachedCustomEventRequests(reason: "System sending all cached events")
        
        self.sendCachedUpsertContactCartRequest()
        
        self.sendCachedContactOrderRequests()
        
        self.sendCachedUpsertContactRequests()
        
        self.sendCachedContactLogoutRequest()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
    func sendCachedCustomEventRequests(reason: String) {
        let customEventRequests = CoreDataManager.shared.customEventRequests.fetchCustomEventRequestsFromCoreData()
        if customEventRequests.count > 0 {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Flushing events blunk. Reason: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .info, reason)
            }
            
            CustomEventsSender().sendCustomEvents(sendCustomEventRequests: customEventRequests)
        }
    }
    
    func sendCachedCustomEventRequestsScheduledTimer() {
        Timer.scheduledTimer(withTimeInterval: CordialApiConfiguration.shared.bulkUploadInterval, repeats: true) { timer in
            self.sendCachedCustomEventRequests(reason: "Scheduled timer")
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
