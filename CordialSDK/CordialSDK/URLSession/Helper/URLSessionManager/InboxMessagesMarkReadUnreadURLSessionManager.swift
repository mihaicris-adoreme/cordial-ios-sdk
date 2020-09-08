//
//  InboxMessagesMarkReadUnreadURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 08.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessagesMarkReadUnreadURLSessionManager {
    
    let inboxMessagesMarkReadUnreadSender = InboxMessagesMarkReadUnreadSender()
    
    func completionHandler(inboxMessagesMarkReadUnreadURLSessionData: InboxMessagesMarkReadUnreadURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let inboxMessagesMarkReadUnreadRequest = inboxMessagesMarkReadUnreadURLSessionData.inboxMessagesMarkReadUnreadRequest
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                self.inboxMessagesMarkReadUnreadSender.completionHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessagesMarkReadUnreadSender.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inboxMessagesMarkReadUnreadSender.logicErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode inbox messages read/unread marks response data. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSDKInboxMessages, type: .error, inboxMessagesMarkReadUnreadRequest.requestID, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(inboxMessagesMarkReadUnreadURLSessionData: InboxMessagesMarkReadUnreadURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inboxMessagesMarkReadUnreadSender.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadURLSessionData.inboxMessagesMarkReadUnreadRequest, error: responseError)
    }
    
}
