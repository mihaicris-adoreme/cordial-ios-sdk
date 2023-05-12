//
//  UpsertContactsURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactsURLSessionManager {
    
    let contactsSender = ContactsSender()
    
    func completionHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, statusCode: Int, responseBody: String) {
        let upsertContactRequests = upsertContactsURLSessionData.upsertContactRequests
        
        switch statusCode {
        case 200:
            self.contactsSender.completionHandler(upsertContactRequests: upsertContactRequests)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            
            self.contactsSender.logicErrorHandler(upsertContactRequests: upsertContactRequests, error: responseError)
        }
    }
    
    func errorHandler(upsertContactsURLSessionData: UpsertContactsURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.contactsSender.systemErrorHandler(upsertContactRequests: upsertContactsURLSessionData.upsertContactRequests, error: responseError)
    }
    
}
