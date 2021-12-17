//
//  InboxMessageDeleteURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessageDeleteURLSessionManager {
    
    let inboxMessageDeleteSender = InboxMessageDeleteSender()
    
    func completionHandler(inboxMessageDeleteURLSessionData: InboxMessageDeleteURLSessionData, statusCode: Int, location: URL) {
        let inboxMessageDeleteRequest = inboxMessageDeleteURLSessionData.inboxMessageDeleteRequest
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch statusCode {
            case 200:
                self.inboxMessageDeleteSender.completionHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            case 401:
                let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessageDeleteSender.systemErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessageDeleteSender.logicErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode delete inbox message response data. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, inboxMessageDeleteRequest.requestID, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(inboxMessageDeleteURLSessionData: InboxMessageDeleteURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inboxMessageDeleteSender.systemErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteURLSessionData.inboxMessageDeleteRequest, error: responseError)
    }
    
    
}
