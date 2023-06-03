//
//  ContactsSenderHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ContactsSenderHelper {
    
    func prepareCoreDataCacheBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        self.removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: upsertContactRequests)
        
        return self.removeUpsertContactRequestIfNotificationTokenNotPresented(upsertContactRequests: upsertContactRequests)
    }
    
    private func removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: [UpsertContactRequest]) {
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            let previousPrimaryKey = internalCordialAPI.getPreviousContactPrimaryKey()
            
            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey && previousPrimaryKey != nil {
                    internalCordialAPI.removeAllCachedData()
                }
            }
        }
    }
    
    private func removeUpsertContactRequestIfNotificationTokenNotPresented(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        
        var returnUpsertContactRequests = [UpsertContactRequest]()
        
        upsertContactRequests.forEach { upsertContactRequest in
            if upsertContactRequest.token != nil {
                returnUpsertContactRequests.append(upsertContactRequest)
            } else {
                CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: [upsertContactRequest])
                
                upsertContactRequests.forEach({ upsertContactRequest in
                    LoggerManager.shared.info(message: "Sending contact failed. Saved to retry later. Request ID: [\(upsertContactRequest.requestID)] Error: [Device token is absent]", category: "CordialSDKUpsertContacts")
                })
            }
        }
        
        return returnUpsertContactRequests
    }

}
