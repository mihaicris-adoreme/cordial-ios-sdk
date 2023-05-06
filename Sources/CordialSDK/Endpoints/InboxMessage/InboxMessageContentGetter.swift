//
//  InboxMessageContentGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessageContentGetter {
    
    static let shared = InboxMessageContentGetter()
    
    private init() {}
    
    var is400StatusReceived = false
    var is403StatusReceived = false
    
    func fetchInboxMessageContent(url: URL, mcID: String, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                // This is S3 - No need check JWT
                
                LoggerManager.shared.info(message: "Fetching inbox message content", category: "CordialSDKInboxMessages")
                
                self.getInboxMessageContent(url: url, mcID: mcID, onSuccess: { response in
                    LoggerManager.shared.info(message: "Inbox message content has been received successfully", category: "CordialSDKInboxMessages")

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
    
    private func getInboxMessageContent(url: URL, mcID: String, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        let request = CordialRequestFactory().getBaseURLRequest(url: url, httpMethod: .GET)
        
        DependencyConfiguration.shared.inboxMessageContentURLSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    onFailure("Fetching inbox message content failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        let response = String(decoding: responseData, as: UTF8.self)
                        
                        CoreDataManager.shared.inboxMessagesContent.putInboxMessageContentToCoreData(mcID: mcID, content: response)
                        
                        onSuccess(response)
                    case 400:
                        if !self.is400StatusReceived {
                            
                            self.is400StatusReceived = true
                            
                            self.getInboxMessageContentTroughthoutUpdatedURL(mcID: mcID, onSuccess: { response in
                                onSuccess(response)
                            }, onFailure: { error in
                                onFailure(error)
                            })
                        } else {
                            onFailure("Fetching inbox message content failed. Error: [URL has been expired]")
                        }
                    case 403:
                        if !self.is403StatusReceived {
                            
                            self.is403StatusReceived = true
                            
                            self.getInboxMessageContentTroughthoutUpdatedURL(mcID: mcID, onSuccess: { response in
                                onSuccess(response)
                            }, onFailure: { error in
                                onFailure(error)
                            })
                        } else {
                            onFailure("Fetching inbox message content failed. Error: [Inbox message URL is not valid]")
                        }
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
            }
        }.resume()
    }
    
    private func getInboxMessageContentTroughthoutUpdatedURL(mcID: String, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
    
        CordialInboxMessageAPI().getInboxMessage(mcID: mcID, onSuccess: { inboxMessage in
            if let url = URL(string: inboxMessage.url) {
                self.fetchInboxMessageContent(url: url, mcID: mcID, onSuccess: { response in
                    onSuccess(response)
                }, onFailure: { error in
                    onFailure(error)
                })
            } else {
                onFailure("Fetching inbox message content failed. Error: [Inbox message URL is not valid]")
            }
        }, onFailure: { error in
            onFailure(error)
        })
    }
}
