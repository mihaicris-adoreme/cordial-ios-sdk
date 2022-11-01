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
                    if self.isLastJSONObjectValues(attributes: attributes) {
                        container.append(self.getObjectValuesJSON(attributes: attributes))
                    } else {
                        container.append("\"\(key)\": { \(self.getObjectValuesJSON(attributes: attributes)) }")
                    }
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
    
    private func isLastJSONObjectValues(attributes: Dictionary<String, JSONValue>) -> Bool {
        var returnValue = false
        
        attributes.forEach { (key: String, value: JSONValue) in
            switch value {
            case is JSONObjectValue:
                returnValue = true
            default:
                break
            }
        }
        
        return returnValue
    }
    
    private func getObjectsValuesJSON(attributes: Dictionary<String, [JSONValue]>) -> String {
        var containerJSONValues = [String]()
        
        attributes.forEach { (key: String, values: [JSONValue]) in
            var containerJSONValue = [String]()
            
            values.forEach { value in
                switch value {
                case is JSONObjectValue:
                    let objectValue = value as! JSONObjectValue
                    if let attributes = objectValue.value {
                        containerJSONValue.append(self.getAttributesJSON(attributes: attributes))
                    }
                case is JSONObjectValues:
                    let objectValues = value as! JSONObjectValues
                    if let attributes = objectValues.value {
                        containerJSONValue.append(self.getObjectValuesJSON(attributes: attributes))
                    }
                case is JSONObjectsValues:
                    let objectsValues = value as! JSONObjectsValues
                    if let attributes = objectsValues.value {
                        containerJSONValue.append(self.getObjectsValuesJSON(attributes: attributes))
                    }
                default:
                    break
                }
            }
            
            containerJSONValues.append("\"\(key)\": { \(containerJSONValue.joined(separator: ", ")) }")
        }
        
        return containerJSONValues.joined(separator: ", ")
    }
    
    private func getPreparedAttributes(attributes: Dictionary<String, AttributeValue>) -> Dictionary<String, AttributeValue> {
        var preparedAttributes: Dictionary<String, AttributeValue> = [:]
        
        var dotsAttributes: [[String]] = [[String]]()
        
        attributes.forEach { (key: String, value: AttributeValue) in
            let keys = key.components(separatedBy: ".")
            
            if keys.count > 1 {
                dotsAttributes.append(keys)
            } else {
                preparedAttributes[key] = value
            }
        }
        
        dotsAttributes.forEach { keys in
            if let value = attributes[keys.joined(separator:".")] {
                self.getPreparedAttributesDictionary(keys: keys, value: value).forEach { (key: String, value: JSONValue) in
                    if let objectValues = value as? JSONObjectValues {
                        if let preparedAttributesKey = preparedAttributes[key] as? JSONObjectValues,
                           let attributeValue = preparedAttributesKey.value,
                           let objectValue = objectValues.value {
                            
                            let mergedAttributes = self.getMergedAttributesObjectWithObject(attributeValue: attributeValue, objectValue: objectValue)
                            
                            preparedAttributes[key] = mergedAttributes
                            
                        } else if let preparedAttributesKey = preparedAttributes[key] as? JSONObjectsValues,
                                  let attributeValues = preparedAttributesKey.value,
                                  let objectValue = objectValues.value {
                            
                            let mergedAttributes = self.getMergedAttributesObjectsWithObject(objectsValue: attributeValues, objectValue: objectValue)
                            
                            preparedAttributes[key] = mergedAttributes
                            
                        } else {
                            preparedAttributes[key] = objectValues
                        }
                    }
                }
            }
        }
        
        return preparedAttributes
    }
    
    private func getPreparedAttributesDictionary(keys: [String], value: AttributeValue) -> Dictionary<String, JSONValue> {
        var preparedAttributes: Dictionary<String, JSONValue> = [:]
        
        if let key = keys.first {
            if keys.count == 1 {
                let objectValue = JSONObjectValue([key: value])
                let objectValues = JSONObjectValues([key: objectValue])
                
                preparedAttributes[key] = objectValues
            } else {
                let subtractedAttributeKeys = self.getSubtractedAttributeKeys(keys: keys)

                let preparedAttributesDictionary = self.getPreparedAttributesDictionary(keys: subtractedAttributeKeys, value: value)
                
                let objectValues = JSONObjectValues(preparedAttributesDictionary)
                
                preparedAttributes[key] = objectValues
            }
        }
        
        return preparedAttributes
    }
    
    private func getSubtractedAttributeKeys(keys: [String]) -> [String] {
        var returnKeys: [String] = []
        
        var index = 0
        keys.forEach { key in
            if index > 0 {
                returnKeys.append(key)
            }
            
            index += 1
        }
        
        return returnKeys
    }
    
    private func getMergedAttributesObjectWithObject(attributeValue: Dictionary<String, JSONValue>, objectValue: Dictionary<String, JSONValue>) -> JSONObjectsValues {
        var mergedAttributes: Dictionary<String, [JSONValue]> = [:]
                
        var addedObjectValueKeys = [String]()
        
        attributeValue.forEach { (key: String, value: JSONValue) in
            var JSONValues = [JSONValue]()
            
            if let objectValues = objectValue[key] {
                JSONValues.append(value)
                JSONValues.append(objectValues)
                
                addedObjectValueKeys.append(key)
                
                mergedAttributes[key] = JSONValues
            } else {
                mergedAttributes[key] = [value]
            }
        }
        
        objectValue.forEach { (key: String, value: JSONValue) in
            if !addedObjectValueKeys.contains(key) {
                mergedAttributes[key] = [value]
            }
        }
    
        return JSONObjectsValues(mergedAttributes)
    }
    
    private func getMergedAttributesObjectsWithObject(objectsValue: Dictionary<String, [JSONValue]>, objectValue: Dictionary<String, JSONValue>) -> JSONObjectsValues {
        var mergedAttributes: Dictionary<String, [JSONValue]> = [:]
                
        var addedObjectValueKeys = [String]()
        
        objectsValue.forEach { (key: String, values: [JSONValue]) in
            var JSONValues = [JSONValue]()
            
            if let objectValues = objectValue[key] {
                values.forEach { value in
                    JSONValues.append(value)
                }

                JSONValues.append(objectValues)
                
                addedObjectValueKeys.append(key)
                
                mergedAttributes[key] = JSONValues
            } else {
                mergedAttributes[key] = values
            }
        }
        
        objectValue.forEach { (key: String, value: JSONValue) in
            if !addedObjectValueKeys.contains(key) {
                mergedAttributes[key] = [value]
            }
        }
        
        return JSONObjectsValues(mergedAttributes)
    }
    
    private func getGeoAttributeJSON(geoValue: GeoValue) -> String {
        return "{ \"city\": \"\(geoValue.city)\", \"country\": \"\(geoValue.country)\", \"postal_code\": \"\(geoValue.postalCode)\", \"state\": \"\(geoValue.state)\", \"street_address\": \"\(geoValue.streetAddress)\", \"street_address2\": \"\(geoValue.streetAddress2)\", \"tz\": \"\(geoValue.timeZone)\" }"
    }
}
