//
//  InAppMessage.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/3/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessage {
    
    func getInAppMessage(mcID: String) {
        if let url = URL(string: CordialApiEndpoints().getInAppMessageURL(mcID: mcID)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            let inAppMessageDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let inAppMessageURLSessionData = InAppMessageURLSessionData(mcID: mcID)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_FETCH_IN_APP_MESSAGE, taskData: inAppMessageURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: inAppMessageDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            inAppMessageDownloadTask.resume()
        }
    }
    
    func isPayloadContainInAppMessage(userInfo: [AnyHashable : Any]) -> Bool {
        if let inApp = userInfo["in-app"] as? Bool, inApp {
            return true
        } else if let inApp = userInfo["in-app"] as? String, inApp == "true" {
            return true
        }
        
        return false
    }

}
