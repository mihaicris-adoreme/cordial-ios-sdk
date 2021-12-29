//
//  UpsertContactCartURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class UpsertContactCartURLSessionManager {
    
    let contactCartSender = ContactCartSender()
    
    func completionHandler(upsertContactCartURLSessionData: UpsertContactCartURLSessionData, statusCode: Int, responseBody: String) {
        let upsertContactCartRequest = upsertContactCartURLSessionData.upsertContactCartRequest
        
        switch statusCode {
        case 200:
            contactCartSender.completionHandler(upsertContactCartRequest: upsertContactCartRequest)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactCartSender.systemErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactCartSender.logicErrorHandler(upsertContactCartRequest: upsertContactCartRequest, error: responseError)
        }
    }
    
    func errorHandler(upsertContactCartURLSessionData: UpsertContactCartURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactCartSender.systemErrorHandler(upsertContactCartRequest: upsertContactCartURLSessionData.upsertContactCartRequest, error: responseError)
    }
}
