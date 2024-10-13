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
        LoggerManager.shared.error(
            message: "\(String(describing: Self.self)).\(#function)): internalCordialAPI.isUserLogin(): \(internalCordialAPI.isUserLogin().description)",
            category: "CordialSDKAddedByAdoreMe"
        )

        if internalCordialAPI.isUserLogin() {
            let previousPrimaryKey = internalCordialAPI.getPreviousContactPrimaryKey()
            
            LoggerManager.shared.error(
                message: "\(String(describing: Self.self)).\(#function)): previousPrimaryKey: \(previousPrimaryKey)",
                category: "CordialSDKAddedByAdoreMe"
            )

            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey && previousPrimaryKey != nil {
                    let value = upsertContactRequest.primaryKey != previousPrimaryKey && previousPrimaryKey != nil
                    LoggerManager.shared.error(
                        message: "\(String(describing: Self.self)).\(#function)): upsertContactRequest.primaryKey != previousPrimaryKey && previousPrimaryKey != nil: \(value.description)",
                        category: "CordialSDKAddedByAdoreMe"
                    )

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
                CoreDataManager.shared.contactRequests.putContactRequests(upsertContactRequests: [upsertContactRequest])
                
                upsertContactRequests.forEach({ upsertContactRequest in
                    LoggerManager.shared.info(message: "Sending contact failed. Saved to retry later. Request ID: [\(upsertContactRequest.requestID)] Error: [Device token is absent]", category: "CordialSDKUpsertContacts")
                })
            }
        }
        
        return returnUpsertContactRequests
    }

}
