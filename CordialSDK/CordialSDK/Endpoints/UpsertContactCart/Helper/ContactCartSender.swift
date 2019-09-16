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
    
    let upsertContactCart = UpsertContactCart()
    
    func upsertContactCart(upsertContactCartRequest: UpsertContactCartRequest) {
        if ReachabilityManager.shared.isConnectedToInternet {
            let upsertContactCart = UpsertContactCart()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                let payload = self.upsertContactCart.getUpsertContactCartJSON(upsertContactCartRequest: upsertContactCartRequest)
                os_log("Sending contact cart. Payload: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, payload)
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
                os_log("Sending contact cart failed. Saved to retry later. Error: [No Internet connection]", log: OSLog.cordialUpsertContactCart, type: .info)
            }
        }
    }
    
    func completionHandler(upsertContactCartRequest: UpsertContactCartRequest) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Contact cart has been sent. Device ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.deviceID))
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
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Sending contact cart failed. Will not retry. Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .error, error.message)
        }
    }
    
}
