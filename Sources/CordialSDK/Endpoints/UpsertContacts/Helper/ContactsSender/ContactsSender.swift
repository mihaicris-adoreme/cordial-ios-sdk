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

        let upsertContactRequests = ContactsSenderHelper().prepareCoreDataCacheBeforeUpsertContacts(upsertContactRequests: upsertContactRequests)
         
        if !upsertContactRequests.isEmpty {
            self.upsertContactsData(upsertContactRequests: upsertContactRequests)
        }
    }
    
    private func upsertContactsData(upsertContactRequests: [UpsertContactRequest]) {
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.setIsCurrentlyUpsertingContacts(true)
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if internalCordialAPI.getCurrentJWT() != nil {
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    upsertContactRequests.forEach({ upsertContactRequest in
                        let payload = self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest)
                        os_log("Sending contact. Request ID: [%{public}@] Payload: %{public}@", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID, payload)
                    })
                }
                
                self.upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests)
                
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            
            CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Sending contact failed. Saved to retry later. Request ID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
                })
            }
        }
    }
    
    func completionHandler(upsertContactRequests: [UpsertContactRequest]) {
        CordialUserDefaults.set(true, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.setIsCurrentlyUpsertingContacts(false)
        
        let currentTimestamp = CordialDateFormatter().getCurrentTimestamp()
        CordialUserDefaults.set(currentTimestamp, forKey: API.USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE)
        
        upsertContactRequests.forEach({ upsertContactRequest in
            if let primaryKey = upsertContactRequest.primaryKey {
                CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
            }
        })
        
        CordialPushNotificationHelper().prepareCurrentPushNotificationStatus()
                 
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
