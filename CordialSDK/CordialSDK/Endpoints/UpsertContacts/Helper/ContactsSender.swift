//
//  ContactsSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactsSender {
    
    let upsertContacts = UpsertContacts()
    
    func upsertContacts(upsertContactRequests: [UpsertContactRequest]) {

        self.prepareCachedDataBeforeUpsertContacts(upsertContactRequests: upsertContactRequests)
        
        let internalCordialAPI = InternalCordialAPI()
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Sending contact. Request ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
                    
                    let payload = self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest)
                    os_log("Payload: %{public}@", log: OSLog.cordialUpsertContacts, type: .info, payload)
                })
            }
        
            if internalCordialAPI.getCurrentJWT() != nil {
                self.upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            internalCordialAPI.setIsCurrentlyUpsertingContacts(true)
            
            CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Sending contact failed. Saved to retry later. Request ID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
                })
            }
        }
    }
    
    private func prepareCachedDataBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) {
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
        
        if internalCordialAPI.isCurrentlyUpsertingContacts() {
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
    
    func completionHandler(upsertContactRequests: [UpsertContactRequest]) {
        InternalCordialAPI().setIsCurrentlyUpsertingContacts(false)
        
        CordialUserDefaults.set(true, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        
        let currentTimestamp = CordialDateFormatter().getCurrentTimestamp()
        CordialUserDefaults.set(currentTimestamp, forKey: API.USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE)
        
        upsertContactRequests.forEach({ upsertContactRequest in
            if let primaryKey = upsertContactRequest.primaryKey {
                CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
            }
        })
        
        CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Contact has been sent. Request ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
            })
        }
    }
    
    func systemErrorHandler(upsertContactRequests: [UpsertContactRequest], error: ResponseError) {
        CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Sending contact failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID, error.message)
            })
        }
    }
    
    func logicErrorHandler(upsertContactRequests: [UpsertContactRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactsLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Sending contact failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .error, upsertContactRequest.requestID, error.message)
            })
        }
    }
}
