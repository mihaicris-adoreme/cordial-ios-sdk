//
//  SendCustomEvents.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendCustomEvents {
    
    func sendCustomEvents(sendCustomEventRequests: [SendCustomEventRequest], onSuccess: @escaping (SendCustomEventResponse) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
        if let url = URL(string: CordialApiEndpoints().getEventsURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendCustomEventsJSON = self.getSendCustomEventsJSON(sendCustomEventRequests: sendCustomEventRequests)
            
            request.httpBody = sendCustomEventsJSON.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let responseData = data, error == nil, let httpResponse = response as? HTTPURLResponse else {
                    if let error = error {
                        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
                        systemError(responseError)
                    } else {
                        let responseError = ResponseError(message: "Unexpected error.", statusCode: nil, responseBody: nil, systemError: nil)
                        systemError(responseError)
                    }
                    
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    let result = SendCustomEventResponse(status: .SUCCESS)
                    onSuccess(result)
                default:
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    logicError(responseError)
                }
            }).resume()
        }
    }
    
    private func getSendCustomEventsJSON(sendCustomEventRequests: [SendCustomEventRequest]) -> String {
        var sendCustomEventsArrayJSON = [String]()
        
        sendCustomEventRequests.forEach { sendCustomEventRequest in
            
            var rootContainer  = [
                "\"deviceId\": \"\(sendCustomEventRequest.deviceID)\"",
                "\"event\": \"\(sendCustomEventRequest.eventName)\"",
                "\"timestamp\": \"\(sendCustomEventRequest.timestamp)\""
            ]
            
            if let primaryKey = sendCustomEventRequest.primaryKey {
                rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
            }
            
            if let mcID = sendCustomEventRequest.mcID {
                rootContainer.append("\"mcID\": \"\(mcID)\"")
            }
            
            if let properties = sendCustomEventRequest.properties {
                rootContainer.append("\"properties\": \(API.getDictionaryJSON(stringDictionary: properties))")
            }
            
            let stringJSON = "{ " + rootContainer.joined(separator: ", ") + " }"
            
            sendCustomEventsArrayJSON.append(stringJSON)
        }
        
        let sendCustomEventsJSON = "[ " + sendCustomEventsArrayJSON.joined(separator: ", ") + " ]"
        
        return sendCustomEventsJSON
    }
}
