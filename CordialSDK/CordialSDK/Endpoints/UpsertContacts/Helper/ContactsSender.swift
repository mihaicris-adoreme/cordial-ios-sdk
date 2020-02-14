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
        
        if let previousPrimaryKey = CordialUserDefaults.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY) {
            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey {
                    CoreDataManager.shared.deleteAllCoreData()
                    InternalCordialAPI().removeCurrentMcID()
                }
            }
        }
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Sending contact. Request ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
                    
                    let payload = self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest)
                    os_log("Payload: %{public}@", log: OSLog.cordialUpsertContacts, type: .info, payload)
                })
            }
        
            if InternalCordialAPI().getCurrentJWT() != nil {
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
        
        CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Contact has been sent. Request ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.requestID)
            })
        }
        
        upsertContactRequests.forEach({ upsertContactRequest in
            if let primaryKey = upsertContactRequest.primaryKey {
                CordialUserDefaults.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
            }
        })
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
