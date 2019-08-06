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
    
    let cordialAPI = CordialAPI()
    
    func updateJWT() {
        if let url = URL(string: self.getSDKSecurityURL()) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            let sdkSecurityGetJWTDownloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
            
            let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT, taskData: nil)
            CordialURLSession.shared.operations[sdkSecurityGetJWTDownloadTask.taskIdentifier] = cordialURLSessionData
            
            sdkSecurityGetJWTDownloadTask.resume()
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

    func onSuccess(JWT: String) {
        InternalCordialAPI().setCurrentJWT(JWT: JWT)
    }
    
    func onError(error: ResponseError) {
        os_log("Getting JWT failed. Error: [%{public}@]", log: OSLog.cordialSDKSecurity, type: .info, error.message)
    }
}
