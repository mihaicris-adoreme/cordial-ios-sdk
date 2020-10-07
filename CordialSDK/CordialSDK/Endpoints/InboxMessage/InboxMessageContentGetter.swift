//
//  InboxMessageContentGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessageContentGetter: NSObject, URLSessionDelegate {
    
    // MARK: URLSessionDelegate
    
    private lazy var inboxMessageContentURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func fetchInboxMessageContent(url: URL, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching inbox message content", log: OSLog.cordialInboxMessages, type: .info)
                }
                
                self.getInboxMessageContent(url: url, onSuccess: { response in
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                        os_log("Inbox message content has been received successfully", log: OSLog.cordialInboxMessages, type: .info)
                    }

                    onSuccess(response)
                }, onFailure: { error in
                    onFailure(error)
                })
                
            } else {
                let error = "Fetching inbox message content failed. Error: [No Internet connection]"
                onFailure(error)
            }
        } else {
            let error = "Fetching inbox message content failed. Error: [User no login]"
            onFailure(error)
        }
    }
    
    private func getInboxMessageContent(url: URL, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)
        
        self.inboxMessageContentURLSession.dataTask(with: request) { data, response, error in
            if let error = error {
                onFailure("Fetching inbox message content failed. Error: [\(error.localizedDescription)]")
                return
            }
            
            if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    let response = String(decoding: responseData, as: UTF8.self)
                    onSuccess(response)
                default:
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    
                    do {
                        if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options : []) as? Dictionary<String, AnyObject> {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                            if let prettyJSON = String(data: jsonData, encoding: .utf8) {
                                onFailure("Fetching inbox message content failed. \(message). JSON: \n \(prettyJSON)")
                            } else {
                                onFailure("Fetching inbox message content failed. Error: [Failed decode response data] \(message)")
                            }
                        } else {
                            onFailure("Fetching inbox message content failed. Error: [Failed decode response data] \(message)")
                        }
                    } catch let error {
                        onFailure("Fetching inbox message content failed. Error: [\(error)] \(message)")
                    }
                }
            } else {
                let error = "Fetching inbox message content failed. Error: [Inbox message payload is absent]"
                onFailure(error)
            }
        }.resume()
    }
}
