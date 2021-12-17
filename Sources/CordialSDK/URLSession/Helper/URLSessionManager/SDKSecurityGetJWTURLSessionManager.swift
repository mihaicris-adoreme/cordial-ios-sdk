//
//  SDKSecurityGetJWTURLSessionManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/6/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SDKSecurityGetJWTURLSessionManager {
    
    func completionHandler(statusCode: Int, location: URL) {
        SDKSecurity.shared.isCurrentlyFetchingJWT = false
        
        do {
            let responseBody = try String(contentsOfFile: location.path)
            
            switch statusCode {
            case 200:
                do {
                    if let responseBodyData = responseBody.data(using: .utf8),
                       let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject] {
                        
                        if let JWT = responseBodyJSON["token"] as? String {
                            SDKSecurity.shared.completionHandler(JWT: JWT)
                        } else {
                            let message = "JWT is absent"
                            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                            SDKSecurity.shared.errorHandler(error: responseError)
                        }
                    } else {
                        let message = "Failed decode response data."
                        let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                        SDKSecurity.shared.errorHandler(error: responseError)
                    }
                } catch let error {
                    let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
                    let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                    SDKSecurity.shared.errorHandler(error: responseError)
                }
            default:
                let message = "Status code: \(statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"
                let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: responseBody, systemError: nil)
                SDKSecurity.shared.errorHandler(error: responseError)
            }
        } catch let error {
            let message = "Failed decode response data. Error: [\(error.localizedDescription)]"
            let responseError = ResponseError(message: message, statusCode: statusCode, responseBody: nil, systemError: nil)
            SDKSecurity.shared.errorHandler(error: responseError)
        }
    }
    
    func errorHandler(error: Error) {
        SDKSecurity.shared.isCurrentlyFetchingJWT = false
        
        let responseError = ResponseError(message: error.localizedDescription, statusCode: nil, responseBody: nil, systemError: error)
        SDKSecurity.shared.errorHandler(error: responseError)
    }
}
