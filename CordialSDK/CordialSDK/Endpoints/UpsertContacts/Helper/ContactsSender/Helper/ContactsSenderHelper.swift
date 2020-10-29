//
//  ContactsSenderHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ContactsSenderHelper {
    
    func prepareDataBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        
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
                    internalCordialAPI.removePreviousContactPrimaryKey()
                }
            }
        }
    }
    
    private func removeUpsertContactRequestIfNotificationTokenNotPresented(upsertContactRequests: [UpsertContactRequest]) -> [UpsertContactRequest] {
        
        var upsertContactRequests = upsertContactRequests
        
        for index in 0...(upsertContactRequests.count - 1) {
            if upsertContactRequests[index].token == nil {
                upsertContactRequests.remove(at: index)
            }
        }
        
        return upsertContactRequests
    }
}
