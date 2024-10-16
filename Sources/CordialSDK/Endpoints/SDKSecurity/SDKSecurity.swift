//
//  SDKSecurity.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 8/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UIKit

class SDKSecurity {
    
    static let shared = SDKSecurity()
    
    private init() {}
    
    let cordialAPI = CordialAPI()
    
    let requestSender = DependencyConfiguration.shared.requestSender
    
    var isCurrentlyFetchingJWT = false
    
    func updateJWT() {
        if !isCurrentlyFetchingJWT {
            if let url = URL(string: self.getSDKSecurityURL()) {
                LoggerManager.shared.info(message: "Fetching JWT", category: "CordialSDKSecurity")
                
                let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
                
                let downloadTask = CordialURLSession.shared.backgroundURLSession.downloadTask(with: request)
                
                let cordialURLSessionData = CordialURLSessionData(taskName: API.DOWNLOAD_TASK_NAME_SDK_SECURITY_GET_JWT, taskData: nil)
                CordialURLSession.shared.setOperation(taskIdentifier: downloadTask.taskIdentifier, data: cordialURLSessionData)
                self.isCurrentlyFetchingJWT = true
                
                self.requestSender.sendRequest(task: downloadTask)
            }
        } else {
            LoggerManager.shared.info(message: "JWT is currently fetching", category: "CordialSDKSecurity")
        }
    }
    
    func getSDKSecurityURL() -> String {
        let accountKey = cordialAPI.getAccountKey()
        let channelKey = cordialAPI.getChannelKey()
        
        let systemName = "iOS"
        let systemVersion = UIDevice.current.systemVersion
        
        let secretString = "{\"accountKey\":\"\(accountKey)\",\"channelKey\":\"\(channelKey)\",\"os\":\"\(systemName)\",\"version\":\"\(systemVersion)\"}"
        
        if #available(iOS 13.0, *) {
            let secret = MD5().getHexCryptoKit(string: secretString)
            
            return CordialApiEndpoints().getSDKSecurityURL(secret: secret)
        } else {
            let secret = MD5().getHexCommonCrypto(string: secretString)
            
            return CordialApiEndpoints().getSDKSecurityURL(secret: secret)
        }
    }

    func completionHandler(JWT: String) {
        self.setJWT(JWT: JWT)
    }
    
    func errorHandler(error: ResponseError) {
        LoggerManager.shared.error(message: "Getting JWT failed. Error: [\(error.message)]", category: "CordialSDKSecurity")
    }
    
    private func setJWT(JWT: String) {
        InternalCordialAPI().setCurrentJWT(JWT: JWT)
         
        LoggerManager.shared.info(message: "JWT has been received successfully", category: "CordialSDKSecurity")
    }
    
    func updateJWTwithCallbacks(onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        if let url = URL(string: self.getSDKSecurityURL()) {
            LoggerManager.shared.info(message: "Fetching JWT", category: "CordialSDKSecurity")
            
            let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .POST)
            
            DependencyConfiguration.shared.updateJWTURLSession.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        onFailure("Failed decode response data. Error: [\(error.localizedDescription)]")
                        return
                    }

                    do {
                        if let responseBodyData = data, let responseBodyJSON = try JSONSerialization.jsonObject(with: responseBodyData, options: []) as? [String: AnyObject], let httpResponse = response as? HTTPURLResponse {

                            switch httpResponse.statusCode {
                            case 200:
                                if let JWT = responseBodyJSON["token"] as? String {
                                    self.setJWT(JWT: JWT)
                                    onSuccess("JWT has been received successfully")
                                } else {
                                    let message = "Getting JWT failed. Error: [JWT is absent]"
                                    onFailure(message)
                                }
                            default:
                                let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                                let error = "Getting JWT failed. Error: [\(message)]"

                                onFailure(error)
                            }
                        } else {
                            let error = "Failed decode JWT response data"
                            onFailure(error)
                        }
                    } catch let error {
                        LoggerManager.shared.error(message: "Failed decode JWT response data. Error: [\(error.localizedDescription)]", category: "CordialSDKSecurity")
                    }
                }
            }.resume()
        }
    }
}
