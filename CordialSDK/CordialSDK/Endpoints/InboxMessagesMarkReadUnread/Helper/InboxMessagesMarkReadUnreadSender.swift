//
//  InboxMessagesMarkReadUnreadSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessagesMarkReadUnreadSender {
    
    func sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if InternalCordialAPI().getCurrentJWT() != nil {
                    InboxMessagesMarkReadUnread().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
                } else {
                    let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                    self.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
                    
                    SDKSecurity.shared.updateJWT()
                }
            } else {
                let responseError = ResponseError(message: "No Internet connection", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
            }
        } else {
            let responseError = ResponseError(message: "User no login", statusCode: nil, responseBody: nil, systemError: nil)
            self.systemErrorHandler(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, error: responseError)
        }
    }
    
    func completionHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Inbox messages read/unread marks have been sent. Request ID: [%{public}@]", log: OSLog.cordialSDKInboxMessages, type: .info, inboxMessagesMarkReadUnreadRequest.requestID)
        }
    }
    
    func systemErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending inbox messages read/unread marks failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSDKInboxMessages, type: .info, inboxMessagesMarkReadUnreadRequest.requestID, error.message)
        }
    }
    
    func logicErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInboxMessagesMarkReadUnreadLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Sending inbox messages read/unread marks failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialSDKInboxMessages, type: .error, inboxMessagesMarkReadUnreadRequest.requestID, error.message)
        }
    }
}
