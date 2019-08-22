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
            self.upsertContactCartIfUserLoggedIn(upsertContactCartRequest: upsertContactCartRequest)
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact cart failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialUpsertContactCart, type: .info)
            }
        }
    }
    
    func completionHandler(upsertContactCartRequest: UpsertContactCartRequest) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Contact cart sent. Device ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
        }
    }
    
    func systemErrorHandler(upsertContactCartRequest: UpsertContactCartRequest, error: ResponseError) {
        CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact cart failed. Saved to retry later. Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, error.message)
        }
    }
    
    func logicErrorHandler(error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactCartLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact cart failed. Will not retry. For viewing exact error see .cordialUpsertContactCartLogicError notification in notification center.", log: OSLog.cordialUpsertContactCart, type: .info)
        }
    }
    
    private func upsertContactCartIfUserLoggedIn(upsertContactCartRequest: UpsertContactCartRequest) {
        if CordialAPI().getContactPrimaryKey() != nil {
            let upsertContactCart = UpsertContactCart()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact cart. Device ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                upsertContactCart.upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact cart failed. Saved to retry later. Error: [primaryKey is nil]", log: OSLog.cordialUpsertContactCart, type: .info)
            }
        }
    }
}
