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
            self.sendCachedCustomEventRequests(reason: "System sending all cached events")
            
            self.sendCachedUpsertContactCartRequest()
            
            self.sendCachedContactOrderRequests()
        }
        
        self.sendCachedContactLogoutRequest()
        
        InAppMessagesQueueManager().fetchInAppMessagesFromQueue()
    }
    
    func sendCachedCustomEventRequests(reason: String) {
        ThreadQueues.shared.queueSendCustomEventRequest.sync(flags: .barrier) {
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
                    self.sendCachedCustomEventRequests(reason: "Scheduled timer")
                }
            } 
        }
    }
    
    private func sendCachedUpsertContactCartRequest() {
        ThreadQueues.shared.queueUpsertContactCartRequest.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                if let upsertContactCartRequest = CoreDataManager.shared.contactCartRequest.getContactCartRequestFromCoreData() {
                    ContactCartSender().upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
                }
            }
        }
    }
    
    private func sendCachedContactOrderRequests() {
        ThreadQueues.shared.queueSendContactOrderRequest.sync(flags: .barrier) {
            if InternalCordialAPI().isUserLogin() {
                let sendContactOrderRequests = CoreDataManager.shared.contactOrderRequests.getContactOrderRequestsFromCoreData()
                if sendContactOrderRequests.count > 0 {
                    ContactOrdersSender().sendContactOrders(sendContactOrderRequests: sendContactOrderRequests)
                }
            }
        }
    }
    
    private func sendCachedUpsertContactRequests() {
        ThreadQueues.shared.queueUpsertContactRequest.sync(flags: .barrier) {
            let upsertContactRequests = CoreDataManager.shared.contactRequests.getContactRequestsFromCoreData()
            if upsertContactRequests.count > 0 {
                ContactsSender().upsertContacts(upsertContactRequests: upsertContactRequests)
            }
        }
    }
    
    private func sendCachedContactLogoutRequest() {
        ThreadQueues.shared.queueSendContactLogoutRequest.sync(flags: .barrier) {
            if let sendContactLogoutRequest = CoreDataManager.shared.contactLogoutRequest.getContactLogoutRequestFromCoreData() {
                ContactLogoutSender().sendContactLogout(sendContactLogoutRequest: sendContactLogoutRequest)
            }
        }
    }
}
