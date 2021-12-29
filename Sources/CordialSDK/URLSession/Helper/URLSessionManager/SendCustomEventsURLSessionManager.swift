//
//  SendCustomEventsURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/7/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class SendCustomEventsURLSessionManager {
    
    let customEventsSender = CustomEventsSender()
    
    func completionHandler(sendCustomEventsURLSessionData: SendCustomEventsURLSessionData, statusCode: Int, responseBody: String) {
        let sendCustomEventRequests = sendCustomEventsURLSessionData.sendCustomEventRequests
        
        switch statusCode {
        case 200:
            self.customEventsSender.completionHandler(sendCustomEventRequests: sendCustomEventRequests)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.customEventsSender.systemErrorHandler(sendCustomEventRequests: sendCustomEventRequests, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.customEventsSender.logicErrorHandler(sendCustomEventRequests: sendCustomEventRequests, error: responseError)
        }
    }
    
    func errorHandler(sendCustomEventsURLSessionData: SendCustomEventsURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.customEventsSender.systemErrorHandler(sendCustomEventRequests: sendCustomEventsURLSessionData.sendCustomEventRequests, error: responseError)
    }
}
