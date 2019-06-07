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
        if let primaryKey = CordialAPI().getContactPrimaryKey(), let previousPrimaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY) {
            if primaryKey != previousPrimaryKey {
                CoreDataManager.shared.deleteAllCoreData()
            }
        }
        
        if ReachabilityManager.shared.isConnectedToInternet {
            os_log("Sending contacts:", log: OSLog.upsertContacts, type: .info)
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Device ID: [%{public}@]", log: OSLog.upsertContacts, type: .info, upsertContactRequest.deviceID)
            })
        
            self.upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests,
                onSuccess: { result in
                    os_log("Contacts sent:", log: OSLog.upsertContacts, type: .info)
                    upsertContactRequests.forEach({ upsertContactRequest in
                        os_log("Contact payload: [%{public}@]", log: OSLog.upsertContacts, type: .info, self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest))
                    })
                }, systemError: { error in
                    CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
                    os_log("Sending contact failed. Saved to retry later.", log: OSLog.upsertContacts, type: .info)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .upsertContactsLogicError, object: error)
                    os_log("Sending contact failed. Will not retry.", log: OSLog.upsertContacts, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
            os_log("Sending contact failed. Saved to retry later.", log: OSLog.upsertContacts, type: .info)
        }
    }
    
}
