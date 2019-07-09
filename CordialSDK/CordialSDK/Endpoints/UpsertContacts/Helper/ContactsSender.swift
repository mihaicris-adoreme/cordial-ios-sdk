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
        
        if let previousPrimaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PREVIOUS_PRIMARY_KEY) {
            upsertContactRequests.forEach { upsertContactRequest in
                if upsertContactRequest.primaryKey != previousPrimaryKey {
                    CoreDataManager.shared.deleteAllCoreData()
                    UserDefaults.standard.removeObject(forKey: API.USER_DEFAULTS_KEY_FOR_PUSH_NOTIFICATION_MCID)
                }
            }
        }
        
        if ReachabilityManager.shared.isConnectedToInternet {
            os_log("Sending contacts:", log: OSLog.cordialUpsertContacts, type: .info)
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Device ID: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, upsertContactRequest.deviceID)
            })
        
            self.upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests,
                onSuccess: { result in
                    os_log("Contacts sent:", log: OSLog.cordialUpsertContacts, type: .info)
                    upsertContactRequests.forEach({ upsertContactRequest in
                        os_log("Contact payload: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, self.upsertContacts.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest))
                    })
                }, systemError: { error in
                    CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
                    os_log("Sending contact failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialUpsertContacts, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .cordialUpsertContactsLogicError, object: error)
                    os_log("Sending contact failed. Will not retry. For viewing exact error see .upsertContactsLogicError notification in notification center.", log: OSLog.cordialUpsertContacts, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactRequests.setContactRequestsToCoreData(upsertContactRequests: upsertContactRequests)
            os_log("Sending contact failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialUpsertContacts, type: .info)
        }
    }
    
}
