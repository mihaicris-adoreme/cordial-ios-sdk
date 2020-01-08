//
//  SendContactLogout.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactLogout {
    
    let internalCordialAPI = InternalCordialAPI()
    
    func sendContactLogout(sendContactLogoutRequest: SendContactLogoutRequest) {
        if let url = URL(string: CordialApiEndpoints().getContactLogoutURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendContactLogoutJSON = getSendContactLogoutJSON(sendContactLogoutRequest: sendContactLogoutRequest)
            request.httpBody = sendContactLogoutJSON.data(using: .utf8)
            
            let sendContactLogoutDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let sendContactLogoutURLSessionData = SendContactLogoutURLSessionData(sendContactLogoutRequest: sendContactLogoutRequest)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SEND_CONTACT_LOGOUT, taskData: sendContactLogoutURLSessionData)
            CordialURLSession.shared.operations[sendContactLogoutDownloadTask.taskIdentifier] = cordialURLSessionData
            
            sendContactLogoutDownloadTask.resume()
        }
    }
    
    func getSendContactLogoutJSON(sendContactLogoutRequest: SendContactLogoutRequest) -> String {
        var rootContainer  = [
            "\"deviceId\": \"\(internalCordialAPI.getDeviceIdentifier())\""
        ]
        
        if let primaryKey = sendContactLogoutRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        let sendContactLogoutJSON = "{ \(rootContainerString) }"
        
        return sendContactLogoutJSON
    }
}
