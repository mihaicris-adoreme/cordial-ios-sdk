//
//  SendContactLogoutURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class SendContactLogoutURLSessionManager {
    
    let contactLogoutSender = ContactLogoutSender()
    
    func completionHandler(sendContactLogoutURLSessionData: SendContactLogoutURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let sendContactLogoutRequest = sendContactLogoutURLSessionData.sendContactLogoutRequest
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                contactLogoutSender.completionHandler(sendContactLogoutRequest: sendContactLogoutRequest)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactLogoutSender.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactLogoutSender.logicErrorHandler(sendContactLogoutRequest: sendContactLogoutRequest, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode send contact logout response data. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSendContactLogout, type: .error, sendContactLogoutRequest.requestID, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(sendContactLogoutURLSessionData: SendContactLogoutURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactLogoutSender.systemErrorHandler(sendContactLogoutRequest: sendContactLogoutURLSessionData.sendContactLogoutRequest, error: responseError)
    }
    
}
