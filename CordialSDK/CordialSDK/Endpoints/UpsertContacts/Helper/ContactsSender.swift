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
    
    func upsertContacts(upsertContactRequests: [UpsertContactRequest]) {
        if ReachabilityManager.shared.isConnectedToInternet && CordialAPI().getContactPrimaryKey() != nil {
            let upsertContacts = UpsertContacts()
            
            os_log("Sending contacts:", log: OSLog.upsertContacts, type: .info)
            upsertContactRequests.forEach({ upsertContactRequest in
                os_log("Device ID: [%{PUBLIC}@]", log: OSLog.upsertContacts, type: .info, upsertContactRequest.deviceID)
            })
        
            upsertContacts.upsertContacts(upsertContactRequests: upsertContactRequests,
                onSuccess: { result in
                    os_log("Contacts sent:", log: OSLog.upsertContacts, type: .info)
                    upsertContactRequests.forEach({ upsertContactRequest in
                        os_log("Device ID: [%{PUBLIC}@]", log: OSLog.upsertContacts, type: .info, upsertContactRequest.deviceID)
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
