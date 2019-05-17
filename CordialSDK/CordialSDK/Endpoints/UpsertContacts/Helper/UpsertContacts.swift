//
//  UpsertContacts.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContacts {
    
    public func upsertContacts(upsertContactRequests: [UpsertContactRequest], onSuccess: @escaping (UpsertContactResponse) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
    
        if let url = URL(string: CordialApiEndpoints().getContactsURL()) {
            
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let upsertContactRequestsJSON = self.getUpsertContactRequestsJSON(upsertContactRequests: upsertContactRequests)
            
            request.httpBody = upsertContactRequestsJSON.data(using: .utf8)
            
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
                    let result = UpsertContactResponse(status: .UPDATED)
                    
                    CordialAPI().sendCacheFromCoreData()
                    
                    onSuccess(result)
                case 201:
                    let result = UpsertContactResponse(status: .CREATED)
                    
                    CordialAPI().sendCacheFromCoreData()
                    
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
    
    private func getUpsertContactRequestsJSON(upsertContactRequests: [UpsertContactRequest]) -> String {
        
        var upsertContactsArrayJSON = [String]()
        
        upsertContactRequests.forEach { upsertContactRequest in
            var rootContainer  = [
                "\"deviceId\": \"\(upsertContactRequest.deviceID)\"",
                "\"subscribeStatus\": \"\(upsertContactRequest.subscribeStatus)\""
            ]
            
            if let token = upsertContactRequest.token {
                rootContainer.append("\"token\": \"\(token)\"")
            }
            
            if let primaryKey = upsertContactRequest.primaryKey {
                rootContainer.append("\"primaryKey\": \"\(primaryKey)\"")
            }
            
            if let attributes = upsertContactRequest.attributes {
                rootContainer.append("\"attributes\": \(API.getDictionaryJSON(stringDictionary: attributes))")
            }
            
            let upsertContactJSON = "{ " + rootContainer.joined(separator: ", ") + " }"
            
            upsertContactsArrayJSON.append(upsertContactJSON)
        }
        
        let upsertContactsJSON = "[ " + upsertContactsArrayJSON.joined(separator: ", ") + " ]"
        
        return upsertContactsJSON
    }
}
