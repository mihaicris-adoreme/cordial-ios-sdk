//
//  ContactCartSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/25/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class ContactCartSender {
    
    func upsertContactCart(upsertContactCartRequest: UpsertContactCartRequest) {
        if ReachabilityManager.shared.isConnectedToInternet {
            let upsertContactCart = UpsertContactCart()
            
            os_log("Sending contact cart. Device ID: [%{PUBLIC}@]", log: OSLog.upsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
            
            upsertContactCart.upsertContactCart(upsertContactCartRequest: upsertContactCartRequest,
                onSuccess: { result in
                    os_log("Contact cart sent. Device ID: [%{PUBLIC}@]", log: OSLog.upsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
                }, systemError: { error in
                    CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                    os_log("Sending contact cart failed. Saved to retry later.", log: OSLog.upsertContactCart, type: .info)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .upsertContactCartLogicError, object: error)
                    os_log("Sending contact cart failed. Will not retry.", log: OSLog.upsertContactCart, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            os_log("Sending contact cart failed. Saved to retry later.", log: OSLog.upsertContactCart, type: .info)
        }
    }
}
