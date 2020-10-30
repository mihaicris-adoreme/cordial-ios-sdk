//
//  ContactsSenderHelper.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class ContactsSenderHelper {
    
    func prepareCoreDataCacheBeforeUpsertContacts(upsertContactRequests: [UpsertContactRequest]) {
        self.removeCacheIfCurrentPrimaryKeyNotEqualToPreviousPrimaryKey(upsertContactRequests: upsertContactRequests)
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
}
