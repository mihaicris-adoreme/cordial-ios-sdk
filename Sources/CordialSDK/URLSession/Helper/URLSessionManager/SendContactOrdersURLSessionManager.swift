//
//  SendContactOrdersURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class SendContactOrdersURLSessionManager {
    
    let contactOrdersSender = ContactOrdersSender()
    
    func completionHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, statusCode: Int, responseBody: String) {
        let sendContactOrderRequests = sendContactOrdersURLSessionData.sendContactOrderRequests
        
        switch statusCode {
        case 200:
            contactOrdersSender.completionHandler(sendContactOrderRequests: sendContactOrderRequests)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactOrdersSender.logicErrorHandler(sendContactOrderRequests: sendContactOrderRequests, error: responseError)
        }
    }
    
    func errorHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrdersURLSessionData.sendContactOrderRequests, error: responseError)
    }
}
