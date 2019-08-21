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
    
    func completionHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                contactOrdersSender.completionHandler(sendContactOrderRequests: sendContactOrdersURLSessionData.sendContactOrderRequests)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrdersURLSessionData.sendContactOrderRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                contactOrdersSender.logicErrorHandler(error: responseError)
            }
        } catch let error {
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode response data. Error: [%{public}@]", log: OSLog.cordialSendContactOrders, type: .error, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(sendContactOrdersURLSessionData: SendContactOrdersURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        contactOrdersSender.systemErrorHandler(sendContactOrderRequests: sendContactOrdersURLSessionData.sendContactOrderRequests, error: responseError)
    }
}
