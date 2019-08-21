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
        
        // Remove all cache data if had exist previously primary key equal to current setting primary key
        if let previousPrimaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY) {
            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey {
                    CoreDataManager.shared.deleteAllCoreData()
                    UserDefaults.standard.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
                }
            }
        }
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialOSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contacts:", log: OSLog.cordialUpsertContacts, type: .info)
                upsertContactRequests.forEach({ upsertContactRequest in
                    os_log("Device ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.deviceID)
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
            
            if CordialOSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialUpsertContacts, type: .info)
            }
        }
    }
    
    func completionHandler(upsertContactRequests: [UpsertContactRequest]) {
        if CordialOSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Contacts sent:", log: OSLog.cordialUpsertContacts, type: .info)
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Contact payload: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest))
            })
        }
        
        upsertContactRequests.forEach({ upsertContactRequest in
            if let primaryKey = upsertContactRequest.primaryKey {
                UserDefaults.standard.set(primaryKey, forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
            }
        })
        
        InternalCordialAPI().sendCacheFromCoreData()
    }
    
    func systemErrorHandler(upsertContactRequests: [UpsertContactRequest], error: ResponseError) {
        CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
        
        if CordialOSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, error.message)
        }
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactsLogicError, object: error)
        
        if CordialOSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact failed. Will not retry. For viewing exact error see .cordialUpsertContactsLogicError notification in notification center.", log: OSLog.cordialUpsertContacts, type: .info)
        }
    }
}
