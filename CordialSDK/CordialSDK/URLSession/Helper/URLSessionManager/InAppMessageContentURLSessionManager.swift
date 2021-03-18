//
//  InAppMessageContentURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageContentURLSessionManager {
    
    let inAppMessageContentGetter = InAppMessageContentGetter()
        
    func completionHandler(inAppMessageContentURLSessionData: InAppMessageContentURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        let mcID = inAppMessageContentURLSessionData.mcID
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                do {
                    if let responseBodyData = responseBody.data(using: .utf8),
                       let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject],
                       let html = responseBodyJSON["content"] as? String,
                       let inAppMessageParams = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageParamsByMcID(mcID: mcID) {
                        
                        let inAppMessageData = InAppMessage().getInAppMessageData(inAppMessageParams: inAppMessageParams, html: html)
                        
                        self.inAppMessageContentGetter.completionHandler(inAppMessageData: inAppMessageData)
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
                    }
                } catch let error {
                    let message = "Failed decode response data. mcID: [\(mcID)] Error: [\(error.localizedDescription)]"
                    let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                    self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
                }
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
            }
        } catch let error {
            let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
            let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: nil, systemError: nil)
            self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
        }
    }
    
    func errorHandler(inAppMessageContentURLSessionData: InAppMessageContentURLSessionData, error: Error) {
        let mcID = inAppMessageContentURLSessionData.mcID
        
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inAppMessageContentGetter.errorHandler(mcID: mcID, error: responseError)
    }
    
}
