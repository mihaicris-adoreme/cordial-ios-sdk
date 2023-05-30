//
//  InboxMessageDeleteSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessageDeleteSender {
    
    func sendInboxMessageDelete(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if internalCordialAPI.getCurrentJWT() != nil {
                    InboxMessageDelete().sendInboxMessageDelete(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
                } else {
                    let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                    self.systemErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest, error: responseError)
                    
                    SDKSecurity.shared.updateJWT()
                }
            } else {
                let responseError = ResponseError(message: "No Internet connection", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest, error: responseError)
            }
        } else {
             let responseError = ResponseError(message: "User no login", statusCode: nil, responseBody: nil, systemError: nil)
             self.systemErrorHandler(inboxMessageDeleteRequest: inboxMessageDeleteRequest, error: responseError)
        }
    }
    
    func completionHandler(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        LoggerManager.shared.info(message: "Inbox message has been successfully deleted. Request ID: [\(inboxMessageDeleteRequest.requestID)]", category: "CordialSDKInboxMessages")
    }
    
    func systemErrorHandler(inboxMessageDeleteRequest: InboxMessageDeleteRequest, error: ResponseError) {
        CoreDataManager.shared.inboxMessageDelete.putInboxMessageDeleteRequestToCoreData(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
        
        LoggerManager.shared.info(message: "Deleting inbox message failed. Saved to retry later. Request ID: [\(inboxMessageDeleteRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKInboxMessages")
    }
    
    func logicErrorHandler(inboxMessageDeleteRequest: InboxMessageDeleteRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInboxMessageDeleteRequestLogicError, object: error)

        LoggerManager.shared.error(message: "Deleting inbox message failed. Will not retry. Request ID: [\(inboxMessageDeleteRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKInboxMessages")
    }

}
