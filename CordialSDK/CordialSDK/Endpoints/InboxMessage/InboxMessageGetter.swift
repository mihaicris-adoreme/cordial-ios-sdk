//
//  InboxMessageGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 05.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessageGetter: NSObject, URLSessionDelegate {
    
    // MARK: URLSessionDelegate
    
    private lazy var inboxMessageURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func fetchInboxMessage(contactKey: String, mcID: String, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching inbox message", log: OSLog.cordialInboxMessages, type: .info)
                }
                
                if internalCordialAPI.getCurrentJWT() != nil {
                    self.getInboxMessage(contactKey: contactKey, mcID: mcID, onSuccess: { response in
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                            os_log("Inbox message has been received successfully", log: OSLog.cordialInboxMessages, type: .info)
                        }

                        onSuccess(response)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                } else {
                    SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                        self.fetchInboxMessage(contactKey: contactKey, mcID: mcID, onSuccess: onSuccess, onFailure: onFailure)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                }
            } else {
                let error = "Fetching single inbox message failed. Error: [No Internet connection]"
                onFailure(error)
            }
        } else {
            let error = "Fetching single inbox message failed. Error: [User no login]"
            onFailure(error)
        }
    }
    
    private func getInboxMessage(contactKey: String, mcID: String, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessageURL(contactKey: contactKey, mcID: mcID)) {
            let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)
            
            self.inboxMessageURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    onFailure("Fetching single inbox message failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        self.parseResponseJSON(mcID: mcID, responseData: responseData, onSuccess: { response in
                            onSuccess(response)
                        }, onFailure: { error in
                            onFailure(error)
                        })
                        
                    case 401:
                        SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                            self.getInboxMessage(contactKey: contactKey, mcID: mcID, onSuccess: onSuccess, onFailure: onFailure)
                        }, onFailure: { error in
                            onFailure(error)
                        })
                    default:
                        let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        
                        do {
                            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options : []) as? Dictionary<String, AnyObject> {
                                
                                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                                if let prettyJSON = String(data: jsonData, encoding: .utf8) {
                                    onFailure("Fetching single inbox message failed. \(message). JSON: \n \(prettyJSON)")
                                } else {
                                    onFailure("Fetching single inbox message failed. Error: [Failed decode response data] \(message)")
                                }
                            } else {
                                onFailure("Fetching single inbox message failed. Error: [Failed decode response data] \(message)")
                            }
                        } catch let error {
                            onFailure("Fetching single inbox message failed. Error: [\(error)] \(message)")
                        }
                    }
                } else {
                    let error = "Fetching single inbox message failed. Error: [Inbox message payload is absent]"
                    onFailure(error)
                }
            }.resume()
        }
    }
    
    private func parseResponseJSON(mcID: String, responseData: Data, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        do {
            if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject],
                let result = responseJSON["success"] as? Bool,
                result {
                
                if let messageJSON = responseJSON["message"] as? [String: AnyObject] {
                        
                    var url: String?
                    var title: String?
                    var read: Bool?
                    var sentAt: String?
                    
                    var messageError = String()
                    
                    messageJSON.forEach { key, value in
                        switch key {
                            case "url":
                                if let valueURL = value as? String {
                                    url = valueURL
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "url IS NIL"
                                }
                            case "title":
                                if let valueTitle = value as? String {
                                    title = valueTitle
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "title IS NIL"
                                }
                            case "read":
                                if let valueRead = value as? Bool {
                                    read = valueRead
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "read IS NIL"
                                }
                            case "sentAt":
                                if let valueSentAt = value as? String {
                                    if CordialDateFormatter().isValidTimestamp(timestamp: valueSentAt) {
                                        sentAt = valueSentAt
                                    } else {
                                        if !messageError.isEmpty {
                                            messageError += ". "
                                        }
                                        
                                        messageError += "sentAt IS NOT VALID"
                                    }
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "sentAt IS NIL"
                                }
                            default: break
                        }
                    }
                    
                    if let messageURL = url,
                        let messageTitle = title,
                        let messageRead = read,
                        let messageSentAt = sentAt {
                        
                        let inboxMessage = InboxMessage(mcID: mcID, url: messageURL, title: messageTitle, isRead: messageRead, sentAt: messageSentAt)
                        
                        onSuccess(inboxMessage)
                    } else {
                        onFailure("Fetching single inbox message failed. Error: [Failed decode response data. \(messageError)]")
                    }
                } else {
                    onFailure("Fetching single inbox message failed. Inbox message is absent by mcID: [\(mcID)]")
                }
            } else {
                onFailure("Fetching single inbox message failed. Error: [success: false]")
            }
        } catch let error {
            onFailure("Fetching single inbox message failed. Error: [\(error.localizedDescription)]")
        }
    }
    
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
        
        self.inboxMessageURLSession.dataTask(with: request) { data, response, error in
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
