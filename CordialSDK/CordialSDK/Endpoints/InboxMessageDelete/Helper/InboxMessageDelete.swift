//
//  InboxMessageDelete.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessageDelete {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func sendInboxMessageDelete(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        if let primaryKey = inboxMessageDeleteRequest.primaryKey, let url = URL(string: CordialApiEndpoints().getInboxMessageDeleteURL(contactKey: primaryKey, mcID: inboxMessageDeleteRequest.mcID)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .DELETE)
            
            let inboxMessageDeleteDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inboxMessageDeleteURLSessionData = InboxMessageDeleteURLSessionData(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_DELETE_INBOX_MESSAGE, taskData: inboxMessageDeleteURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: inboxMessageDeleteDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: inboxMessageDeleteDownloadTask)
        }
    }
    
}
