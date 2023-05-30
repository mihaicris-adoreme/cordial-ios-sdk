//
//  InboxMessagesMarkReadUnreadSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesMarkReadUnreadSender {
    
    func sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if internalCordialAPI.getCurrentJWT() != nil {
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
        LoggerManager.shared.info(message: "Inbox messages read/unread marks have been sent. Request ID: [\(inboxMessagesMarkReadUnreadRequest.requestID)]", category: "CordialSDKInboxMessages")
    }
    
    func systemErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        CoreDataManager.shared.inboxMessagesMarkReadUnread.putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        
        LoggerManager.shared.info(message: "Sending inbox messages read/unread marks failed. Saved to retry later. Request ID: [\(inboxMessagesMarkReadUnreadRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKInboxMessages")
    }
    
    func logicErrorHandler(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest, error: ResponseError) {
        NotificationCenter.default.post(name: .cordialInboxMessagesMarkReadUnreadLogicError, object: error)
        
        LoggerManager.shared.error(message: "Sending inbox messages read/unread marks failed. Will not retry. Request ID: [\(inboxMessagesMarkReadUnreadRequest.requestID)] Error: [\(error.message)]", category: "CordialSDKInboxMessages")
        
        if error.statusCode == 422, let responseBody = error.responseBody {
            let inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks = self.getInboxMessagesMarkReadUnreadRequestWithoutBrokenMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest, responseBody: responseBody)
            
            if !inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks.markAsReadMcIDs.isEmpty ||
                !inboxMessagesMarkReadUnreadRequestWithoutBrokenMarks.markAsUnreadMcIDs.isEmpty {
    
                LoggerManager.shared.info(message: "Request [\(inboxMessagesMarkReadUnreadRequest.requestID)] has valid inbox messages read/unread marks. Sending again those read/unread marks.", category: "CordialSDKInboxMessages")
                
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
                LoggerManager.shared.error(message: "Failed decode response", category: "CordialSDKInboxMessages")
            }
        } catch let error {
            LoggerManager.shared.error(message: "Error: [\(error.localizedDescription)]", category: "CordialSDKInboxMessages")
        }
        
        return (errorMarkAsReadIDs, errorMarkAsUnreadIDs)
    }
}
