//
//  SendContactLogout.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactLogout {
    func sendContactLogout(sendContactLogoutRequest: SendContactLogoutRequest, onSuccess: @escaping (SendContactLogoutResponse) -> Void, systemError: @escaping (ResponseError) -> Void, logicError: @escaping (ResponseError) -> Void) -> Void {
        if let url = URL(string: CordialApiEndpoints().getContactLogoutURL()) {
            var request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sendContactLogoutJSON = getSendContactLogoutJSON(sendContactLogoutRequest: sendContactLogoutRequest)
            request.httpBody = sendContactLogoutJSON.data(using: .utf8)
            
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
                    let result = SendContactLogoutResponse(status: .SUCCESS)
                    onSuccess(result)
                case 403:
                    SDKSecurity().updateJWT()
                    
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    systemError(responseError)
                default:
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    logicError(responseError)
                }
            }).resume()
        }
    }
    
    private func getSendContactLogoutJSON(sendContactLogoutRequest: SendContactLogoutRequest) -> String {
        let rootContainer  = [
            "\"deviceId\": \"\(sendContactLogoutRequest.deviceID)\"",
            "\"primaryKey\": \"\(sendContactLogoutRequest.primaryKey)\""
        ]
        
        let rootContainerString = rootContainer.joined(separator: ", ")
        
        let sendContactLogoutJSON = "{ \(rootContainerString) }"
        
        return sendContactLogoutJSON
    }
}
