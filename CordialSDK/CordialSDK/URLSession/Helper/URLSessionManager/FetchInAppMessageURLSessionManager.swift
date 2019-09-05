//
//  FetchInAppMessageURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class FetchInAppMessageURLSessionManager {
    
    let inAppMessageGetter = InAppMessageGetter()
    
    func completionHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                if let responseBodyData = responseBody.data(using: .utf8) {
                    let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as! [String: AnyObject]
                    if let html = responseBodyJSON["content"] as? String {
                        var top = 15
                        var right = 10
                        var bottom = 20
                        var left = 10
                        
                        var type: InAppMessageType
                        var displayType: InAppMessageDisplayType
                        let expirationTime = "2020-07-25T13:58:01Z"
                        
                        switch inAppMessageURLSessionData.mcID {
                        case "test_modal":
                            type = InAppMessageType.modal
                            displayType = InAppMessageDisplayType.displayOnAppOpenEvent
                        case "test_fullscreen":
                            type = InAppMessageType.fullscreen
                            displayType = InAppMessageDisplayType.displayOnAppOpenEvent
                            
                            top = 0
                            right = 0
                            bottom = 0
                            left = 0
                        case "test_banner_up":
                            type = InAppMessageType.banner_up
                            displayType = InAppMessageDisplayType.displayImmediately
                            
                            let height = 20
                            
                            top = 5
                            right = 5
                            bottom = Int(100 - Double(height) / 100.0 * 100)
                            left = 5
                        case "test_banner_bottom":
                            type = InAppMessageType.banner_bottom
                            displayType = InAppMessageDisplayType.displayImmediately
                            
                            let height = 20
                            
                            top = Int(100 - Double(height) / 100.0 * 100)
                            right = 5
                            bottom = 5
                            left = 5
                        default:
                            type = InAppMessageType.modal
                            displayType = InAppMessageDisplayType.displayOnAppOpenEvent
                        }
                        
                        let inAppMessageData = InAppMessageData(mcID: inAppMessageURLSessionData.mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: InternalCordialAPI().getDateFromTimestamp(timestamp: expirationTime))
                        
                        self.inAppMessageGetter.completionHandler(inAppMessageData: inAppMessageData)
                    } else {
                        let message = "Failed to parse IAM response."
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.inAppMessageGetter.logicErrorHandler(error: responseError)
                    }
                }
            case 401:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageGetter.systemErrorHandler(mcID: inAppMessageURLSessionData.mcID, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.inAppMessageGetter.logicErrorHandler(error: responseError)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Failed decode response data. Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .error, error.localizedDescription)
            }
        }
    }
    
    func errorHandler(inAppMessageURLSessionData: InAppMessageURLSessionData, error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.inAppMessageGetter.systemErrorHandler(mcID: inAppMessageURLSessionData.mcID, error: responseError)
    }

}
