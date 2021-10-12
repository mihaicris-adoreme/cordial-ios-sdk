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
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                // This is S3 - No need check JWT 
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching IAM content has been started with mcID: [%{public}@]", log: OSLog.cordialInAppMessageContent, type: .info, mcID)
                }
                
                let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)

                let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)

                let inAppMessageContentURLSessionData = InAppMessageContentURLSessionData(mcID: mcID)
                let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE_CONTENT, taskData: inAppMessageContentURLSessionData)
                
                CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)

                self.requestSender.sendRequest(task: downloadTask)
            } else {
                let message = "Fetching IAM content failed with mcID: [\(mcID)]. Error: [No Internet connection]"
                let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
                self.errorHandler(mcID: mcID, error: responseError)
            }
        } else {
            let message = "Fetching IAM content failed with mcID: [\(mcID)]. Error: [User no login]"
            let responseError = ResponseError(message: message, statusCode: nil, responseBody: nil, systemError: nil)
            self.errorHandler(mcID: mcID, error: responseError)
        }
    }
    
    func completionHandler(inAppMessageData: InAppMessageData) {
        InAppMessage().prepareAndShowInAppMessage(inAppMessageData: inAppMessageData)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            guard let htmlData = inAppMessageData.html.data(using: .utf8) else { return }
            let payloadSize = API.sizeFormatter(data: htmlData, formatter: .useAll)
            
            os_log("IAM content has been successfully fetch with mcID: [%{public}@]. Payload size: %{public}@.", log: OSLog.cordialInAppMessageContent, type: .info, inAppMessageData.mcID, payloadSize)
        }
    }
    
    func errorHandler(mcID: String, error: ResponseError) {
        InAppMessageGetter().fetchInAppMessage(mcID: mcID)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("%{public}@", log: OSLog.cordialInAppMessageContent, type: .error, error.message)
        }
    }
    
}
