//
//  InboxMessages.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessages: NSObject, URLSessionDelegate {
        
    // MARK: URLSessionDelegate
    
    lazy var inboxMessagesURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func getInboxMessages(contactKey: String, onComplete: @escaping (_ response: [InboxMessage]) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(contactKey: contactKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            self.inboxMessagesURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    onError("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        self.parseResponseJSON(responseData: responseData, onComplete: { response in
                            onComplete(response)
                        }, onError: { error in
                            onError(error)
                        })
                        
                    case 401:
                        SDKSecurity.shared.updateJWTwithCallbacks(onComplete: { response in
                            self.getInboxMessages(contactKey: contactKey, onComplete: onComplete, onError: onError)
                        }, onError: { error in
                            onError(error)
                        })
                    default:
                        let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        
                        do {
                            if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options : []) as? Dictionary<String, AnyObject> {
                                
                                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                                if let prettyJSON = String(data: jsonData, encoding: .utf8) {
                                    onError("Fetching inbox messages failed. \(message). JSON: \n \(prettyJSON)")
                                } else {
                                    onError("Fetching inbox messages failed. Error: [Failed decode response data] \(message)")
                                }
                            } else {
                                onError("Fetching inbox messages failed. Error: [Failed decode response data] \(message)")
                            }
                        } catch let error {
                            onError("Fetching inbox messages failed. Error: [\(error)] \(message)")
                        }
                    }
                } else {
                    let error = "Fetching inbox messages failed. Error: [Inbox messages payload is absent]"
                    onError(error)
                }
            }.resume()
        }
    }
    
    private func parseResponseJSON(responseData: Data, onComplete: @escaping (_ response: [InboxMessage]) -> Void, onError: @escaping (_ error: String) -> Void) {
        do {
            if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject],
                let result = responseJSON["success"] as? Bool,
                result {
                
                var inboxMessages = [InboxMessage]()
                
                if let messagesJSON = responseJSON["messages"] as? [[String: AnyObject]] {
                    messagesJSON.forEach { messageJSON in
                        
                        var id: String?
                        var html: String?
                        var customKeyValuePairs: [String: String]?
                        var title: String?
                        var read: Bool?
                        var sentAt: String?
                        
                        var messageError = String()
                        
                        messageJSON.forEach { key, value in
                            switch key {
                                case "_id":
                                    if let valueID = value as? String {
                                        id = valueID
                                    } else {
                                        if !messageError.isEmpty {
                                            messageError += ". "
                                        }
                                        
                                        messageError += "_id IS NIL"
                                    }
                                case "html":
                                    if let valueHTML = value as? String {
                                        html = valueHTML
                                    } else {
                                        if !messageError.isEmpty {
                                            messageError += ". "
                                        }
                                        
                                        messageError += "html IS NIL"
                                    }
                                case "customKeyValuePairs":
                                    if let valueCustomKeyValuePairs = value as? [String: String] {
                                        customKeyValuePairs = valueCustomKeyValuePairs
                                    } else {
                                        customKeyValuePairs = [String: String]()
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
                        
                        if let messageID = id,
                            let messageHTML = html,
                            let messageCustomKeyValuePairs = customKeyValuePairs,
                            let messageTitle = title,
                            let messageRead = read,
                            let messageSentAt = sentAt {
                            
                            let inboxMessage = InboxMessage(id: messageID, html: messageHTML, customKeyValuePairs: messageCustomKeyValuePairs, title: messageTitle, read: messageRead, sentAt: messageSentAt)
                            
                            inboxMessages.append(inboxMessage)
                        } else {
                            onError("Fetching inbox messages failed. Error: [Failed decode response data. \(messageError)]")
                        }
                    }
                    
                    onComplete(inboxMessages)
                } else {
                    onComplete(inboxMessages)
                }
            } else {
                onError("Fetching inbox messages failed. Error: [success: false]")
            }
        } catch let error {
            onError("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
        }
    }
}
