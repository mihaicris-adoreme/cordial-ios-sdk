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
    
    func completionHandler(sendCustomEventsURLSessionData: SendCustomEventsURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                self.customEventsSender.completionHandler(sendCustomEventRequests: sendCustomEventsURLSessionData.sendCustomEventRequests)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.customEventsSender.systemErrorHandler(sendCustomEventRequests: sendCustomEventsURLSessionData.sendCustomEventRequests, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.customEventsSender.logicErrorHandler(sendCustomEventRequests: sendCustomEventsURLSessionData.sendCustomEventRequests, error: responseError)
            }
        } catch let error {
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode response data. Error: [%{public}@]", log: OSLog.cordialSendCustomEvents, type: .error, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(sendCustomEventsURLSessionData: SendCustomEventsURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.customEventsSender.systemErrorHandler(sendCustomEventRequests: sendCustomEventsURLSessionData.sendCustomEventRequests, error: responseError)
    }
}
