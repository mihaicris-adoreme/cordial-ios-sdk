//
//  SDKSecurity.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UIKit
import os.log

class SDKSecurity {
    
    static let shared = SDKSecurity()
    
    private init(){}
    
    let cordialAPI = CordialAPI()
    
    var isCurrentlyFetchingJWT = false
    
    func updateJWT() {
        if !isCurrentlyFetchingJWT {
            if let url = URL(string: self.getSDKSecurityURL()) {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching JWT", log: OSLog.cordialSDKSecurity, type: .info)
                }
                
                let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
                
                let sdkSecurityGetJWTDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
                
                let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT, taskData: nil)
                CordialURLSession.shared.setOperation(taskIdentifier: sdkSecurityGetJWTDownloadTask.taskIdentifier, data: cordialURLSessionData)
                self.isCurrentlyFetchingJWT = true
                
                sdkSecurityGetJWTDownloadTask.resume()
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("JWT is currently fetching", log: OSLog.cordialSDKSecurity, type: .info)
            }
        }
    }
    
    func getSDKSecurityURL() -> String {
        let accountKey = cordialAPI.getAccountKey()
        let channelKey = cordialAPI.getChannelKey()
        
        let currentDevice = UIDevice.current
        let systemName = currentDevice.systemName
        let systemVersion = currentDevice.systemVersion
        
        let secretString = "{\"accountKey\":\"\(accountKey)\",\"channelKey\":\"\(channelKey)\",\"os\":\"\(systemName)\",\"version\":\"\(systemVersion)\"}"
        let secret = MD5().getHex(string: secretString)
        
        return CordialApiEndpoints().getSDKSecurityURL(secret: secret)
    }

    func completionHandler(JWT: String) {
        InternalCordialAPI().setCurrentJWT(JWT: JWT)
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("JWT has been received successfully", log: OSLog.cordialSDKSecurity, type: .info)
        }
    }
    
    func errorHandler(error: ResponseError) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Getting JWT failed. Error: [%{public}@]", log: OSLog.cordialSDKSecurity, type: .error, error.message)
        }
    }
}
