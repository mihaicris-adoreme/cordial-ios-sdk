//
//  SendCustomEvents.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendCustomEvents {
    
    let cordialAPI = CordialAPI()
    let internalCordialAPI = InternalCordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func sendCustomEvents(sendCustomEventRequests: [SendCustomEventRequest]) {
        
        if let url = URL(string: CordialApiEndpoints().getCustomEventsURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendCustomEventsJSON = self.getSendCustomEventsJSON(sendCustomEventRequests: sendCustomEventRequests)
            
            request.httpBody = sendCustomEventsJSON.data(using: .utf8)
            
            let sendCustomEventsDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let sendCustomEventsURLSessionData = SendCustomEventsURLSessionData(sendCustomEventRequests: sendCustomEventRequests)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SEND_CUSTOM_EVENTS, taskData: sendCustomEventsURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: sendCustomEventsDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: sendCustomEventsDownloadTask)
        }
    }
    
    func getSendCustomEventsJSON(sendCustomEventRequests: [SendCustomEventRequest]) -> String {
        var sendCustomEventsArrayJSON = [String]()
        
        sendCustomEventRequests.forEach { sendCustomEventRequest in
            let stringJSON = self.getSendCustomEventJSON(sendCustomEventRequest: sendCustomEventRequest)
            
            sendCustomEventsArrayJSON.append(stringJSON)
        }
        
        let sendCustomEventsStringJSON = sendCustomEventsArrayJSON.joined(separator: ", ")
        
        let sendCustomEventsJSON = "[ \(sendCustomEventsStringJSON) ]"
        
        return sendCustomEventsJSON
    }
    
    func getSendCustomEventJSON(sendCustomEventRequest: SendCustomEventRequest) -> String {
        
        var rootContainer  = [
            "\"deviceId\": \"\(self.internalCordialAPI.getDeviceIdentifier())\"",
            "\"event\": \"\(sendCustomEventRequest.eventName)\"",
            "\"timestamp\": \"\(sendCustomEventRequest.timestamp)\""
        ]
        
        if let primaryKey = sendCustomEventRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        if let mcID = sendCustomEventRequest.mcID {
            rootContainer.append("\"mcID\": \"\(mcID)\"")
        }
        
        if let latitude = sendCustomEventRequest.latitude, latitude != 0.0, let longitude = sendCustomEventRequest.longitude, longitude != 0.0 {
            rootContainer.append("\"lat\": \(latitude)")
            rootContainer.append("\"lon\": \(longitude)")
        }
        
        if let properties = sendCustomEventRequest.properties {
            rootContainer.append("\"properties\": \(API.getDictionaryJSON(stringDictionary: properties))")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        return "{ \(rootContainerString) }"
    }
}
