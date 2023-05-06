//
//  ContactCartSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/25/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ContactCartSender {
    
    let upsertContactCart = UpsertContactCart()
    
    func upsertContactCart(upsertContactCartRequest: UpsertContactCartRequest) {
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                self.upsertContactCartData(upsertContactCartRequest: upsertContactCartRequest)
            } else {
                CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
                
                LoggerManager.shared.info(message: "Sending contact cart failed. Saved to retry later. Request ID: [\(upsertContactCartRequest.requestID)] Error: [No Internet connection]", category: "CordialSDKUpsertContactCart")
            }
        } else {
            CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
            
            LoggerManager.shared.info(message: "Sending contact cart failed. Saved to retry later. Request ID: [\(upsertContactCartRequest.requestID)] Error: [User no login]", category: "CordialSDKUpsertContactCart")
        }
    }
    
    private func upsertContactCartData(upsertContactCartRequest: UpsertContactCartRequest) {
        let upsertContactCart = UpsertContactCart()
                
        if InternalCordialAPI().getCurrentJWT() != nil {
            LoggerManager.shared.info(message: "Sending contact cart. Request ID: [\(upsertContactCartRequest.requestID)]", category: "CordialSDKUpsertContactCart")
            
            let payload = self.upsertContactCart.getUpsertContactCartJSON(upsertContactCartRequest: upsertContactCartRequest)
            LoggerManager.shared.info(message: "Payload: \(payload)", category: "CordialSDKUpsertContactCart")
            
            upsertContactCart.upsertContactCart(upsertContactCartRequest: upsertContactCartRequest)
        } else {
            let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        }
    }
    
    func completionHandler(upsertContactCartRequest: UpsertContactCartRequest) {
        LoggerManager.shared.info(message: "Contact cart has been sent. Request ID: [\(String(upsertContactCartRequest.requestID))]", category: "CordialSDKUpsertContactCart")
    }
    
    func systemErrorHandler(upsertContactCartRequest: UpsertContactCartRequest, error: ResponseError) {
        CoreDataManager.shared.contactCartRequest.setContactCartRequestToCoreData(upsertContactCartRequest: upsertContactCartRequest)
        
        LoggerManager.shared.info(message: "Sending contact cart failed. Saved to retry later. Request ID: [\(upsertContactCartRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKUpsertContactCart")
    }
    
    func logicErrorHandler(upsertContactCartRequest: UpsertContactCartRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialUpsertContactCartLogicError, object: error)
        
        LoggerManager.shared.error(message: "Sending contact cart failed. Will not retry. Request ID: [\(upsertContactCartRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKUpsertContactCart")
    }
}
