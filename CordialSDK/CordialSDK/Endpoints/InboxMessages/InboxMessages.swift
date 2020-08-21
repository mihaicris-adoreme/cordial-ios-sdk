//
//  InboxMessages.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessages {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func getInboxMessages(primaryKey: String) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(primaryKey: primaryKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            let inboxMessageDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inboxMessagesURLSessionData = InboxMessagesURLSessionData(primaryKey: primaryKey)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_INBOX_MESSAGES, taskData: inboxMessagesURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: inboxMessageDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: inboxMessageDownloadTask)
        }
    }
    
}
