//
//  SDKSecurityGetJWTURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import os.log

class SDKSecurityGetJWTURLSessionManager {
    
    let sdkSecurity = SDKSecurity()
    
    func completionHandler(httpResponse: HTTPURLResponse, location: URL) {
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch httpResponse.statusCode {
            case 200:
                if let responseBodyData = responseBody.data(using: .utf8) {
                    let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as! [String: AnyObject]
                    if let JWT = responseBodyJSON["token"] as? String {
                        self.sdkSecurity.completionHandler(JWT: JWT)
                    } else {
                        let message = "JWT is absent"
                        let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                        self.sdkSecurity.errorHandler(error: responseError)
                    }
                }
            default:
                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                let responseError = ResponseError(message: message, statusCode: httpResponse.statusCode, responseBody: responseBody, systemError: nil)
                self.sdkSecurity.errorHandler(error: responseError)
            }
        } catch {
            os_log("Failed decode response data", log: OSLog.cordialSDKSecurity, type: .error)
        }
    }
    
    func errorHandler(error: Error) {
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        self.sdkSecurity.errorHandler(error: responseError)
    }
}
