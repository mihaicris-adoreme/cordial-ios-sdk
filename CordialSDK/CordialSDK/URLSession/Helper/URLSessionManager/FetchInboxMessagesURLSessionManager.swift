//
//  FetchInboxMessagesURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class FetchInboxMessagesURLSessionManager {
    
    let inboxMessagesGetter = InboxMessagesGetter()
    
    func completionHandler(inboxMessagesURLSessionData: InboxMessagesURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let primaryKey = inboxMessagesURLSessionData.primaryKey
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                self.inboxMessagesGetter.completionHandler(primaryKey: primaryKey, responseBody: responseBody)
            case 401: 
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessagesGetter.errorHandler(primaryKey: primaryKey, error: responseError)

                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessagesGetter.errorHandler(primaryKey: primaryKey, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode response with primaryKey: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, primaryKey, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(inboxMessagesURLSessionData: InboxMessagesURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        inboxMessagesGetter.errorHandler(primaryKey: inboxMessagesURLSessionData.primaryKey, error: responseError)
    }
}
