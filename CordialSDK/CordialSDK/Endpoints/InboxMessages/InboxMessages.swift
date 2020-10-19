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
    
    private lazy var inboxMessagesURLSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    func getInboxMessages(pageRequest: PageRequest, inboxPageFilter: InboxPageFilter?, contactKey: String, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let queryItems = self.getURLQueryItems(pageRequest: pageRequest, inboxPageFilter: inboxPageFilter)
        
        if var urlComponents = URLComponents(string: CordialApiEndpoints().getInboxMessagesURL(contactKey: contactKey)) {
            urlComponents.queryItems = queryItems
            
            if let url = urlComponents.url {
                let request = CordialRequestFactory().getCordialURLRequest(url: url, httpMethod: .GET)
                self.inboxMessagesURLSession.dataTask(with: request) { data, response, error in
                    if let error = error {
                        onFailure("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
                        return
                    }
                    
                    if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                        switch httpResponse.statusCode {
                        case 200:
                            self.parseResponseJSON(responseData: responseData, onSuccess: { response in
                                onSuccess(response)
                            }, onFailure: { error in
                                onFailure(error)
                            })
                            
                        case 401:
                            SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                                self.getInboxMessages(pageRequest: pageRequest, inboxPageFilter: inboxPageFilter, contactKey: contactKey, onSuccess: onSuccess, onFailure: onFailure)
                            }, onFailure: { error in
                                onFailure(error)
                            })
                        default:
                            let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                            
                            do {
                                if let jsonObject = try JSONSerialization.jsonObject(with: responseData, options : []) as? Dictionary<String, AnyObject> {
                                    
                                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

                                    if let prettyJSON = String(data: jsonData, encoding: .utf8) {
                                        onFailure("Fetching inbox messages failed. \(message). JSON: \n \(prettyJSON)")
                                    } else {
                                        onFailure("Fetching inbox messages failed. Error: [Failed decode response data] \(message)")
                                    }
                                } else {
                                    onFailure("Fetching inbox messages failed. Error: [Failed decode response data] \(message)")
                                }
                            } catch let error {
                                onFailure("Fetching inbox messages failed. Error: [\(error)] \(message)")
                            }
                        }
                    } else {
                        let error = "Fetching inbox messages failed. Error: [Inbox messages payload is absent]"
                        onFailure(error)
                    }
                }.resume()
            }
        }
    }
    
    private func getURLQueryItems(pageRequest: PageRequest, inboxPageFilter: InboxPageFilter?) -> [URLQueryItem] {
        var queryItems = [
            URLQueryItem(name: "page", value: String(pageRequest.page)),
            URLQueryItem(name: "perPage", value: String(pageRequest.size))
        ]

        let cordialDateFormatter = CordialDateFormatter()
        
        if let inboxPageFilter = inboxPageFilter {
            
            if let fromDate = inboxPageFilter.fromDate {
                let fromData = cordialDateFormatter.getTimestampFromDate(date: fromDate)
                queryItems += [ URLQueryItem(name: "filters[sentAt][gt]", value: fromData) ]
            }
            
            if let toDate = inboxPageFilter.toDate {
                let toData = cordialDateFormatter.getTimestampFromDate(date: toDate)
                queryItems += [ URLQueryItem(name: "filters[sentAt][lt]", value: toData) ]
            }
            
            switch inboxPageFilter.isRead {
            case InboxPageFilterIsReadType.NONE: break
            case InboxPageFilterIsReadType.YES:
                queryItems += [ URLQueryItem(name: "filters[read]", value: "true") ]
            case InboxPageFilterIsReadType.NO:
                queryItems += [ URLQueryItem(name: "filters[read]", value: "false") ]
            }
            
        }
        
        return queryItems
    }
    
    private func parseResponseJSON(responseData: Data, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        do {
            if let responseJSON = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject],
               let currentPage = responseJSON["currentPage"] as? Int,
               let lastPage = responseJSON["lastPage"] as? Int,
               let sizePerPage = responseJSON["perPage"] as? Int,
               let sizeTotal = responseJSON["total"] as? Int,
               let result = responseJSON["success"] as? Bool,
               result {
                
                var inboxMessages = [InboxMessage]()
                
                if let messagesJSON = responseJSON["messages"] as? [[String: AnyObject]] {
                    messagesJSON.forEach { messageJSON in
                        
                        var id: String?
                        var url: String?
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
                                case "url":
                                    if let valueURL = value as? String {
                                        url = valueURL
                                    } else {
                                        if !messageError.isEmpty {
                                            messageError += ". "
                                        }
                                        
                                        messageError += "url IS NIL"
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
                            let messageURL = url,
                            let messageRead = read,
                            let messageSentAt = sentAt {
                            
                            let inboxMessage = InboxMessage(mcID: messageID, url: messageURL, isRead: messageRead, sentAt: messageSentAt)
                            
                            inboxMessages.append(inboxMessage)
                        } else {
                            onFailure("Fetching inbox messages failed. Error: [Failed decode response data. \(messageError)]")
                        }
                    }
                }
                
                let inboxPage = InboxPage(content: inboxMessages, total: sizeTotal, size: sizePerPage, current: currentPage, last: lastPage)
                onSuccess(inboxPage)
            } else {
                onFailure("Fetching inbox messages failed. Error: [success: false]")
            }
        } catch let error {
            onFailure("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
        }
    }
}
