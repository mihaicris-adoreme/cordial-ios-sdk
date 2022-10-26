//
//  UpsertContacts.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContacts {
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    func upsertContacts(upsertContactRequests: [UpsertContactRequest]) {
    
        if let url = URL(string: CordialApiEndpoints().getContactsURL()) {
            var request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
            
            let upsertContactRequestsJSON = self.getUpsertContactRequestsJSON(upsertContactRequests: upsertContactRequests)
            
            request.httpBody = upsertContactRequestsJSON.data(using: .utf8)
            
            let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let upsertContactsURLSessionData = UpsertContactsURLSessionData(upsertContactRequests: upsertContactRequests)
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_UPSERT_CONTACTS, taskData: upsertContactsURLSessionData)
            CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
            
            self.requestSender.sendRequest(task: downloadTask)
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
            "\"deviceId\": \"\(InternalCordialAPI().getDeviceIdentifier())\"",
            "\"status\": \"\(upsertContactRequest.status)\""
        ]
        
        if let token = upsertContactRequest.token {
            rootContainer.append("\"token\": \"\(token)\"")
        }
        
        if let primaryKey = upsertContactRequest.primaryKey {
            rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
        }
        
        if let attributes = upsertContactRequest.attributes {
            rootContainer.append("\"attributes\": { \(self.getAttributesJSON(attributes: self.getPreparedAttributes(attributes: attributes))) }")
        }
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        let upsertContactJSON = "{ \(rootContainerString) }"
        
        return upsertContactJSON
    }
    
    private func getAttributesJSON(attributes: Dictionary<String, AttributeValue>) -> String {
        var container = [String]()
        
        attributes.forEach { (key: String, value: AttributeValue) in
            switch value {
            case is NumericValue:
                let numericValue = value as! NumericValue
                
                if let value = numericValue.value {
                    container.append("\"\(key)\": \(value)")
                } else {
                    container.append("\"\(key)\": null")
                }
            case is BooleanValue:
                let booleanValue = value as! BooleanValue
                container.append("\"\(key)\": \(booleanValue.value)")
            case is ArrayValue:
                let arrayValue = value as! ArrayValue
                container.append("\"\(key)\": \(API.getArrayJSON(arrayValue.value))")
            case is StringValue:
                let stringValue = value as! StringValue
                
                if let value = stringValue.value {
                    container.append("\"\(key)\": \"\(value)\"")
                } else {
                    container.append("\"\(key)\": null")
                }
            case is DateValue:
                let dateValue = value as! DateValue
                
                if let value = dateValue.value {
                    container.append("\"\(key)\": \"\(CordialDateFormatter().getTimestampFromDate(date: value))\"")
                } else {
                    container.append("\"\(key)\": null")
                }
            case is GeoValue:
                let geoValue = value as! GeoValue
                container.append("\"\(key)\": \(self.getGeoAttributeJSON(geoValue: geoValue))")
            case is JSONObjectValues:
                let objectValues = value as! JSONObjectValues
                if let attributes = objectValues.value {
                    container.append("\"\(key)\": { \(self.getObjectValuesJSON(attributes: attributes)) }")
                }
            case is JSONObjectsValues:
                let objectsValues = value as! JSONObjectsValues
                if let attributes = objectsValues.value {
                    container.append("\"\(key)\": { \(self.getObjectsValuesJSON(attributes: attributes)) }")
                }
            default:
                break
            }
            
        }
        
        return container.joined(separator: ", ")
    }
    
    private func getObjectValuesJSON(attributes: Dictionary<String, JSONValue>) -> String {
        var container = [String]()

        attributes.forEach { (key: String, value: JSONValue) in
            switch value {
            case is JSONObjectValue:
                let objectValue = value as! JSONObjectValue
                if let attributes = objectValue.value {
                    container.append(self.getAttributesJSON(attributes: attributes))
                }
            case is JSONObjectValues:
                let objectValues = value as! JSONObjectValues
                if let attributes = objectValues.value {
                    container.append("\"\(key)\": { \(self.getObjectValuesJSON(attributes: attributes)) }")
                }
            case is JSONObjectsValues:
                let objectsValues = value as! JSONObjectsValues
                if let attributes = objectsValues.value {
                    container.append("\"\(key)\": { \(self.getObjectsValuesJSON(attributes: attributes)) }")
                }
            default:
                break
            }
        }

        return container.joined(separator: ", ")
    }
    
    private func getObjectsValuesJSON(attributes: [JSONObjectValues]) -> String {
        var container = [String]()
        
        attributes.forEach { objectValues in
            if let attributes = objectValues.value {
                container.append("\(self.getObjectValuesJSON(attributes: attributes))")
            }
        }
        
        return container.joined(separator: ", ")
    }
    
    private func getPreparedAttributes(attributes: Dictionary<String, AttributeValue>) -> Dictionary<String, AttributeValue> {
        var preparedAttributes: Dictionary<String, AttributeValue> = [:]
        
        attributes.forEach { (key: String, value: AttributeValue) in
            let keys = key.components(separatedBy: ".")
            
            if keys.count > 1 {
                var objectValues = JSONObjectValues([:])
                
                for (index, item) in keys.reversed().enumerated() {
                    switch index {
                    case 0:
                        let objectValue = JSONObjectValue([item: value])
                        objectValues = JSONObjectValues([item: objectValue])
                    case keys.count - 1:
                        if let preparedAttribute = preparedAttributes[item] as? JSONObjectValues,
                           let preparedAttributeValue = preparedAttribute.value,
                           let objectValue = objectValues.value {
                            
                            let mergedAttributes = self.getMergedAttributes(attributeValue: preparedAttributeValue, objectValue: objectValue)
                            
                            preparedAttributes[item] = mergedAttributes
                        } else {
                            preparedAttributes[item] = objectValues
                        }
                    default:
                        objectValues = JSONObjectValues([item: objectValues])
                    }
                }
            } else {
                preparedAttributes[key] = value
            }
        }
        
        return preparedAttributes
    }
    
    private func getMergedAttributes(attributeValue: Dictionary<String, JSONValue>, objectValue: Dictionary<String, JSONValue>) -> JSONObjectsValues {
        var objectsValues = [JSONObjectValues]()
        
        let attributeValues = JSONObjectValues(attributeValue)
        let objectValues = JSONObjectValues(objectValue)
        
        objectsValues.append(attributeValues)
        objectsValues.append(objectValues)
        
        return JSONObjectsValues(objectsValues)
    }
    
    private func getGeoAttributeJSON(geoValue: GeoValue) -> String {
        return "{ \"city\": \"\(geoValue.city)\", \"country\": \"\(geoValue.country)\", \"postal_code\": \"\(geoValue.postalCode)\", \"state\": \"\(geoValue.state)\", \"street_address\": \"\(geoValue.streetAddress)\", \"street_address2\": \"\(geoValue.streetAddress2)\", \"tz\": \"\(geoValue.timeZone)\" }"
    }
}
