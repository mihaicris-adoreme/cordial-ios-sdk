//
//  SendContactLogoutURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactLogoutURLSessionManager {
    
    let contactLogoutSender = ContactLogoutSender()
    
    func completionHandler(sendContactLogoutURLSessionData: SendContactLogoutURLSessionData, statusCode: Int, responseBody: String) {
        let sendContactLogoutRequest = sendContactLogoutURLSessionData.sendContactLogoutRequest
        
        switch statusCode {
        case 200:
            contactLogoutSender.completionHandler(sendContactLogoutRequest: sendContactLogoutRequest)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactLogoutSender.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            contactLogoutSender.logicErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
        }
    }
    
    func errorHandler(sendContactLogoutURLSessionData: SendContactLogoutURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactLogoutSender.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutURLSessionData.sendContactLogoutRequest, error: responseError)
    }
    
}
