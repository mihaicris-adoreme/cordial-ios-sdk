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
        if ReachabilityManager.shared.isConnectedToInternet && CordialAPI().getContactPrimaryKey() != nil {
            let upsertContactCart = UpsertContactCart()
            
            os_log("Sending contact cart. Device ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
            
            upsertContactCart.upsertContactCart(upsertContactCartRequest: upsertContactCartRequest,
                onSuccess: { result in
                    os_log("Contact cart sent. Device ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
                }, systemError: { error in
                    CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                    os_log("Sending contact cart failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, error.message)
                }, logicError: { error in
                    NotificationCenter.default.post(name: .cordialUpsertContactCartLogicError, object: error)
                    os_log("Sending contact cart failed. Will not retry. For viewing exact error see .upsertContactCartLogicError notification in notification center.", log: OSLog.cordialUpsertContactCart, type: .info)
                }
            )
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            os_log("Sending contact cart failed. Saved to retry later. Error: [No Internet connection.]", log: OSLog.cordialUpsertContactCart, type: .info)
        }
    }
}
