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

class SDKSecurity: NSObject, URLSessionDelegate {
    
    static let shared = SDKSecurity()
    
    private override init(){}
    
    let cordialAPI = CordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
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
                
                self.requestSender.sendRequest(task: sdkSecurityGetJWTDownloadTask)
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
        self.setJWT(JWT: JWT)
    }
    
    func errorHandler(error: ResponseError) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Getting JWT failed. Error: [%{public}@]", log: OSLog.cordialSDKSecurity, type: .error, error.message)
        }
    }
    
    private func setJWT(JWT: String) {
        InternalCordialAPI().setCurrentJWT(JWT: JWT)
         
         if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
             os_log("JWT has been received successfully", log: OSLog.cordialSDKSecurity, type: .info)
         }
    }
    
    // MARK: URLSessionDelegate
    
    lazy var updateJWTURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func updateJWTwithCallbacks(onComplete: @escaping (_ response: String) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let url = URL(string: self.getSDKSecurityURL()) {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching JWT", log: OSLog.cordialSDKSecurity, type: .info)
            }
            
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .POST)
            
            self.updateJWTURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    onError("Failed decode response data. Error: [\(error.localizedDescription)]")
                    return
                }

                do {
                    if let responseBodyData = data, let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject], let httpResponse = response as? HTTPURLResponse {

                        switch httpResponse.statusCode {
                        case 200:
                            if let JWT = responseBodyJSON["token"] as? String {
                                self.setJWT(JWT: JWT)
                                onComplete("JWT has been received successfully")
                            } else {
                                let message = "Getting JWT failed. Error: [JWT is absent]"
                                onError(message)
                            }
                        default:
                            let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                            let error = "Getting JWT failed. Error: [\(message)]"

                            onError(error)
                        }
                    } else {
                        let error = "Failed decode JWT response data"
                        onError(error)
                    }
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed decode JWT response data. Error: [%{public}@]", log: OSLog.cordialSDKSecurity, type: .error, error.localizedDescription)
                    }
                }
            }.resume()
        }
    }
}
