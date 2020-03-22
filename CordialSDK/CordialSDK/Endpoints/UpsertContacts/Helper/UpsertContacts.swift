//
//  UpsertContacts.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContacts {
    
    let internalCordialAPI = InternalCordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func upsertContacts(upsertContactRequests: [UpsertContactRequest]) {
    
        if let url = URL(string: CordialApiEndpoints().getContactsURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let upsertContactRequestsJSON = self.getUpsertContactRequestsJSON(upsertContactRequests: upsertContactRequests)
            
            request.httpBody = upsertContactRequestsJSON.data(using: .utf8)
            
            let upsertContactsDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let upsertContactsURLSessionData = UpsertContactsURLSessionData(upsertContactRequests: upsertContactRequests)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS, taskData: upsertContactsURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: upsertContactsDownloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: upsertContactsDownloadTask)
        }
    }
    
    private func getUpsertContactRequestsJSON(upsertContactRequests: [UpsertContactRequest]) -> String {
        
        var upsertContactsArrayJSON = [String]()
        
        upsertContactRequests.forEach { upsertContactRequest in
            let upsertContactJSON = self.getUpsertContactRequestJSON(upsertContactRequest: upsertContactRequest)
            
            upsertContactsArrayJSON.append(upsertContactJSON)
        }
        
        let upsertContactsStringJSON = upsertContactsArrayJSON.joined(separator: ", ")
        
        let upsertContactsJSON = "[ \(upsertContactsStringJSON) ]"
        
        return upsertContactsJSON
    }
    
    internal func getUpsertContactRequestJSON(upsertContactRequest: UpsertContactRequest) -> String {
        
        var rootContainer  = [
            "\"deviceId\": \"\(internalCordialAPI.getDeviceIdentifier())\"",
            "\"status\": \"\(upsertContactRequest.status)\""
        ]
        
        if let token = upsertContactRequest.token {
            rootContainer.append("\"token\": \"\(token)\"")
        }
        
        if let primaryKey = upsertContactRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        if let attributes = upsertContactRequest.attributes {
            rootContainer.append("\"attributes\": \(self.getAttributesJSON(attributes: attributes))")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        let upsertContactJSON = "{ \(rootContainerString) }"
        
        return upsertContactJSON
    }
    
    private func getAttributesJSON(attributes: Dictionary<String, AttributeValue>) -> String {
        var dictionaryContainer = [String]()
        
        attributes.forEach { (key: String, value: AttributeValue) in
            switch value {
            case is NumericValue:
                let numericValue = value as! NumericValue
                dictionaryContainer.append("\"\(key)\": \(numericValue.value)")
            case is BooleanValue:
                let booleanValue = value as! BooleanValue
                dictionaryContainer.append("\"\(key)\": \(booleanValue.value)")
            case is ArrayValue:
                let arrayValue = value as! ArrayValue
                dictionaryContainer.append("\"\(key)\": \(API.getStringArrayJSON(stringArray: arrayValue.value))")
            case is StringValue:
                let stringValue = value as! StringValue
                dictionaryContainer.append("\"\(key)\": \"\(stringValue.value)\"")
            case is DateValue:
                let dateValue = value as! DateValue
                dictionaryContainer.append("\"\(key)\": \"\(DateFormatter().getTimestampFromDate(date: dateValue.value))\"")
            default:
                break
            }
            
        }
        
        let stringContainer = dictionaryContainer.joined(separator: ", ")
        
        return "{ \(stringContainer) }"
    }
}
