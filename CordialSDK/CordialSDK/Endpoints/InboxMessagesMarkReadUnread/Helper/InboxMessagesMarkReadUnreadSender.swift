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
            os_log("Inbox messages read/unread marks have been sent. Request ID: [%{public}@]", log: OSLog.cordialInboxMessages, type: .info, inboxMessagesMarkReadUnreadRequest.requestID)
        }
    }
    
    func systemErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Sending inbox messages read/unread marks failed. Saved to retry later. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .info, inboxMessagesMarkReadUnreadRequest.requestID, error.message)
        }
    }
    
    func logicErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInboxMessagesMarkReadUnreadLogicError, object: error)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Sending inbox messages read/unread marks failed. Will not retry. Request ID: [%{public}@] Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, inboxMessagesMarkReadUnreadRequest.requestID, error.message)
        }
        
        if let responseBody = error.responseBody {
            let inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks = self.getInboxMessagesMarkReadUnreadRequestWithoutBrokenMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, responseBody: responseBody)
            
            if !inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks.markAsReadMcIDs.isEmpty ||
                !inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks.markAsUnreadMcIDs.isEmpty {
    
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Request [%{public}@] has valid inbox messages read/unread marks. Sending again those read/unread marks.", log: OSLog.cordialInboxMessages, type: .info, inboxMessagesMarkReadUnreadRequest.requestID)
                }
                
                self.sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks)
            }
        }
    }
    
    private func getInboxMessagesMarkReadUnreadRequestWithoutBrokenMarks(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, responseBody: String) -> InboxMessagesMarkReadUnreadRequest {
        
        let (errorMarkAsReadIDs, errorMarkAsUnreadIDs) = self.getMarkReadUnreadErrorIDs(responseBody: responseBody)
        
        let validMarkAsReadIDs = inboxMessagesMarkReadUnreadRequest.markAsReadMcIDs.enumerated().filter {
            !errorMarkAsReadIDs.contains($0.offset)
        }
        
        let validMarkAsUnreadIDs = inboxMessagesMarkReadUnreadRequest.markAsUnreadMcIDs.enumerated().filter {
            !errorMarkAsUnreadIDs.contains($0.offset)
        }
        
        var markAsReadMcIDs = [String]()
        validMarkAsReadIDs.forEach { validMarkAsReadID in
            markAsReadMcIDs.append(validMarkAsReadID.element)
        }
        
        var markAsUnreadMcIDs = [String]()
        validMarkAsUnreadIDs.forEach { validMarkAsUnreadID in
            markAsUnreadMcIDs.append(validMarkAsUnreadID.element)
        }
        
        return InboxMessagesMarkReadUnreadRequest(requestID: UUID().uuidString, primaryKey: inboxMessagesMarkReadUnreadRequest.primaryKey, markAsReadMcIDs: markAsReadMcIDs, markAsUnreadMcIDs: markAsUnreadMcIDs, date: Date())
    }
    
    private func getMarkReadUnreadErrorIDs(responseBody: String) -> ([Int], [Int]) {
        var errorMarkAsReadIDs = [Int]()
        var errorMarkAsUnreadIDs = [Int]()
        
        do {
            if let responseBodyData = responseBody.data(using: .utf8), let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject] {
                if let errorsJSON = responseBodyJSON["error"]?["errors"] as? [String: AnyObject] {
                    let errors = errorsJSON.keys.map { $0 }
                    errors.forEach { error in
                        if let arrayName = error.components(separatedBy: ".").first,
                           let stringID = error.components(separatedBy: ".").last,
                           let intID = Int(stringID) {
                            
                            switch arrayName {
                            case "markAsReadIds":
                                if !errorMarkAsReadIDs.contains(intID) {
                                    errorMarkAsReadIDs.append(intID)
                                }
                            case "markAsUnReadIds":
                                if !errorMarkAsUnreadIDs.contains(intID) {
                                    errorMarkAsUnreadIDs.append(intID)
                                }
                            default:
                                break
                            }
                        }
                    }
                }
            } else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("Failed decode response", log: OSLog.cordialInboxMessages, type: .error)
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, error.localizedDescription)
            }
        }
        
        return (errorMarkAsReadIDs, errorMarkAsUnreadIDs)
    }
}
