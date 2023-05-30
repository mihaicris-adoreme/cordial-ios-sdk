//
//  InboxMessagesMarkReadUnreadURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 08.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesMarkReadUnreadURLSessionManager {
    
    let inboxMessagesMarkReadUnreadSender = InboxMessagesMarkReadUnreadSender()
    
    func completionHandler(inboxMessagesMarkReadUnreadURLSessionData: InboxMessagesMarkReadUnreadURLSessionData, statusCode: Int, responseBody: String) {
        let inboxMessagesMarkReadUnreadRequest = inboxMessagesMarkReadUnreadURLSessionData.inboxMessagesMarkReadUnreadRequest
        
        switch statusCode {
        case 200:
            self.inboxMessagesMarkReadUnreadSender.completionHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        case 401:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inboxMessagesMarkReadUnreadSender.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
            
            SDKSecurity.shared.updateJWT()
        default:
            let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
            self.inboxMessagesMarkReadUnreadSender.logicErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
        }
    }
    
    func errorHandler(inboxMessagesMarkReadUnreadURLSessionData: InboxMessagesMarkReadUnreadURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inboxMessagesMarkReadUnreadSender.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadURLSessionData.inboxMessagesMarkReadUnreadRequest, error: responseError)
    }
    
}
