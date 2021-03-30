//
//  InboxMessagesMarkReadUnread.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 08.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesMarkReadUnread {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesMarkReadUnreadURL()) {
            var request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
            
            let inboxMessagesMarkReadUnreadJSON = self.getInboxMessagesMarkReadUnreadJSON(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            
            request.httpBody = inboxMessagesMarkReadUnreadJSON.data(using: .utf8)
            
            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inboxMessagesMarkReadUnreadURLSessionData = InboxMessagesMarkReadUnreadURLSessionData(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_INBOX_MESSAGES_READ_UNREAD_MARKS, taskData: inboxMessagesMarkReadUnreadURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: downloadTask)
        }
    }
    
    private func getInboxMessagesMarkReadUnreadJSON(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) -> String {
        
        let internalCordialAPI = InternalCordialAPI()
        
        var rootContainer  = [
            "\"deviceId\": \"\(internalCordialAPI.getDeviceIdentifier())\""
        ]
        
        if let primaryKey = inboxMessagesMarkReadUnreadRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        if !inboxMessagesMarkReadUnreadRequest.markAsReadMcIDs.isEmpty {
            rootContainer.append("\"markAsReadIds\": \(API.getStringArrayJSON(stringArray: inboxMessagesMarkReadUnreadRequest.markAsReadMcIDs))")
        }
        
        if !inboxMessagesMarkReadUnreadRequest.markAsUnreadMcIDs.isEmpty {
            rootContainer.append("\"markAsUnReadIds\": \(API.getStringArrayJSON(stringArray: inboxMessagesMarkReadUnreadRequest.markAsUnreadMcIDs))")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        return "{ \(rootContainerString) }"
    }
}
