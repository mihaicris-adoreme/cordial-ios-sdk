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
            CordialURLSession.shared.operations[inAppMessageDownloadTask.taskIdentifier] = cordialURLSessionData
            
            inAppMessageDownloadTask.resume()
        }
    }

}
