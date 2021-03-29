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
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.upsertContactCartData(upsertContactCartRequest: upsertContactCartRequest)
            } else {
                CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Sending contact cart failed. Saved to retry later. Request ID: [%{public}@] Error: [No Internet connection]", log: OSLog.cordialUpsertContactCart, type: .info, upsertContactCartRequest.requestID)
                }
            }
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact cart failed. Saved to retry later. Request ID: [%{public}@] Error: [User no login]", log: OSLog.cordialUpsertContactCart, type: .info, upsertContactCartRequest.requestID)
            }
        }
    }
    
    private func upsertContactCartData(upsertContactCartRequest: UpsertContactCartRequest) {
        let upsertContactCart = UpsertContactCart()
                
        if InternalCordialAPI().getCurrentJWT() != nil {
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Sending contact cart. Request ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, upsertContactCartRequest.requestID)
                
                let payload = self.upsertContactCart.getUpsertContactCartJSON(upsertContactCartRequest: upsertContactCartRequest)
                os_log("Payload: %{public}@", log: OSLog.cordialUpsertContactCart, type: .info, payload)
            }
            
            upsertContactCart.upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
            
        } else {
            let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        }
    }
    
    func completionHandler(upsertContactCartRequest: UpsertContactCartRequest) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Contact cart has been sent. Request ID: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, String(upsertContactCartRequest.requestID))
        }
    }
    
    func systemErrorHandler(upsertContactCartRequest: UpsertContactCartRequest, error: ResponseError) {
        CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending contact cart failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .info, upsertContactCartRequest.requestID, error.message)
        }
    }
    
    func logicErrorHandler(upsertContactCartRequest: UpsertContactCartRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactCartLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Sending contact cart failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialUpsertContactCart, type: .error, upsertContactCartRequest.requestID, error.message)
        }
    }
    
}
