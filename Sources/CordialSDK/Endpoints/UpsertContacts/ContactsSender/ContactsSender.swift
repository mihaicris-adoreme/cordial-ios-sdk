//
//  ContactsSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UserNotifications

class ContactsSender {
    
    let upsertContacts = UpsertContacts()
    
    func upsertContacts(upsertContactRequests: [UpsertContactRequest]) {

        let upsertContactRequests = ContactsSenderHelper().prepareCoreDataCacheBeforeUpsertContacts(upsertContactRequests: upsertContactRequests)
         
        if !upsertContactRequests.isEmpty {
            let internalCordialAPI = InternalCordialAPI()
            
            upsertContactRequests.forEach({ upsertContactRequest in
                let primaryKey = upsertContactRequest.primaryKey
                
                if primaryKey != CordialAPI().getContactPrimaryKey() || (primaryKey == nil && !internalCordialAPI.isUserLogin()) {
                    DispatchQueue.main.async {
                        let current = UNUserNotificationCenter.current()
                        
                        current.getNotificationSettings { settings in
                            DispatchQueue.main.async {
                                var status = String()
                                
                                if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                                    status = API.PUSH_NOTIFICATION_STATUS_ALLOW
                                } else {
                                    status = API.PUSH_NOTIFICATION_STATUS_DISALLOW
                                }
                                
                                internalCordialAPI.setPushNotificationStatus(status: status, authorizationStatus: settings.authorizationStatus, isSentPushNotificationAuthorizationStatus: true)
                            }
                        }
                    }
                }
                
                internalCordialAPI.setContactPrimaryKey(primaryKey: primaryKey)
            })
            
            self.upsertContactsData(upsertContactRequests: upsertContactRequests)
        }
    }
    
    private func upsertContactsData(upsertContactRequests: [UpsertContactRequest]) {
        let internalCordialAPI = InternalCordialAPI()
        
        internalCordialAPI.setIsCurrentlyUpsertingContacts(true)
        
        if ReachabilityManager.shared.isConnectedToInternet {
            if internalCordialAPI.getCurrentJWT() != nil {
                
                upsertContactRequests.forEach({ upsertContactRequest in
                    internalCordialAPI.setContactAttributes(attributes: upsertContactRequest.attributes)
                    
                    let payload = self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest, isLogs: false)
                    LoggerManager.shared.info(message: "Sending contact. Request ID: [\(upsertContactRequest.requestID)] Payload: \(payload)", category: "CordialSDKUpsertContacts")
                })
                
                self.upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests)
                
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            
            CoreDataManager.shared.contactRequests.putContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
            
            upsertContactRequests.forEach({ upsertContactRequest in
                LoggerManager.shared.info(message: "Sending contact failed. Saved to retry later. Request ID: [\(upsertContactRequest.requestID)] Error: [No Internet connection]", category: "CordialSDKUpsertContacts")
            })
        }
    }
    
    func completionHandler(upsertContactRequests: [UpsertContactRequest]) {
        CoreDataManager.shared.contactRequests.removeContactRequestsFromCoreData(upsertContactRequests: upsertContactRequests)
        
        CordialUserDefaults.set(true, forKey: API.USER_DEFAULTS_KEY_FOR_IS_USER_LOGIN)
        
        let currentTimestamp = CordialDateFormatter().getCurrentTimestamp()
        CordialUserDefaults.set(currentTimestamp, forKey: API.USER_DEFAULTS_KEY_FOR_UPSERT_CONTACTS_LAST_UPDATE_DATE)
        
        InternalCordialAPI().setIsCurrentlyUpsertingContacts(false)
        
        PushNotificationHelper().prepareCurrentPushNotificationStatus()
                 
        CoreDataManager.shared.coreDataSender.sendCacheFromCoreData()
    
        upsertContactRequests.forEach({ upsertContactRequest in
            LoggerManager.shared.info(message: "Contact has been sent. Request ID: [\(upsertContactRequest.requestID)]", category: "CordialSDKUpsertContacts")
        })
    }
    
    func systemErrorHandler(upsertContactRequests: [UpsertContactRequest], error: ResponseError) {
        CoreDataManager.shared.contactRequests.putContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
        
        upsertContactRequests.forEach({ upsertContactRequest in
            LoggerManager.shared.info(message: "Sending contact failed. Saved to retry later. Request ID: [\(upsertContactRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKUpsertContacts")
        })
    }
    
    func logicErrorHandler(upsertContactRequests: [UpsertContactRequest], error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactsLogicError, object: error)
        
        CoreDataManager.shared.contactRequests.removeContactRequestsFromCoreData(upsertContactRequests: upsertContactRequests)
        
        upsertContactRequests.forEach({ upsertContactRequest in
            LoggerManager.shared.error(message: "Sending contact failed. Will not retry. Request ID: [\(upsertContactRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKUpsertContacts")
        })
    }
}
