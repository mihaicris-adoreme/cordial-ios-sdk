//
//  InAppMessageContentGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InAppMessageContentGetter {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func fetchInAppMessageContent(mcID: String, url: URL) {
        let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)

        let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

        let inAppMessageContentURLSessionData = InAppMessageContentURLSessionData(mcID: mcID)
        let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT, taskData: inAppMessageContentURLSessionData)
        
        CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

        self.requestSender.sendRequest(task: downloadTask)
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        InAppMessage().prepareAndShowInAppMessage(inAppMessageData: inAppMessageData)
    }
    
    func errorHandler(mcID: String, error: ResponseError) {
        InAppMessageGetter().fetchInAppMessage(mcID: mcID)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("%{public}@", log: OSLog.cordialInAppMessageContent, type: .error, error.message)
        }
    }
    
}
