//
//  InboxMessageGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 05.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessageGetter {
    
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
            
            DependencyConfiguration.shared.inboxMessageURLSession.dataTask(with: request) { data, response, error in
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
                    var urlExpireAt: String?
                    var read: Bool?
                    var sentAt: String?
                    var metadata: String?
                                        
                    var messageError = String()
                    
                    let cordialDateFormatter = CordialDateFormatter()
                    
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
                            case "urlExpireAt":
                                if let valueUrlExpireAt = value as? String {
                                    if cordialDateFormatter.isValidTimestamp(timestamp: valueUrlExpireAt) {
                                        urlExpireAt = valueUrlExpireAt
                                    } else {
                                        if !messageError.isEmpty {
                                            messageError += ". "
                                        }
                                        
                                        messageError += "urlExpireAt IS NOT VALID"
                                    }
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "urlExpireAt IS NIL"
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
                                    if cordialDateFormatter.isValidTimestamp(timestamp: valueSentAt) {
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
                            case "metadata":
                                if value.count > 0,
                                   let valueData = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                                    
                                    metadata = String(decoding: valueData, as: UTF8.self)
                                } else {
                                    if !messageError.isEmpty {
                                        messageError += ". "
                                    }
                                    
                                    messageError += "metadata IS NIL"
                                }
                            default: break
                        }
                    }
                    
                    if let messageURL = url,
                        let messageUrlExpireAt = urlExpireAt,
                        let messageDateUrlExpireAt = cordialDateFormatter.getDateFromTimestamp(timestamp: messageUrlExpireAt),
                        let messageRead = read,
                        let messageSentAt = sentAt,
                        let messageDateSentAt = cordialDateFormatter.getDateFromTimestamp(timestamp: messageSentAt) {
                        
                        let inboxMessage = InboxMessage(mcID: mcID, url: messageURL, urlExpireAt: messageDateUrlExpireAt, isRead: messageRead, sentAt: messageDateSentAt, metadata: metadata)
                        
                        CoreDataManager.shared.inboxMessagesCache.putInboxMessageToCoreData(inboxMessage: inboxMessage)
                        
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
}
