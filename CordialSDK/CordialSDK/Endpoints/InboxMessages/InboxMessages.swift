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
    
    func getInboxMessages(urlKey: String, onComplete: @escaping (_ response: String) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let url = URL(string: CordialApiEndpoints().getInboxMessagesURL(urlKey: urlKey)) {
            let request = CordialRequestFactory().getURLRequest(url: url, httpMethod: .GET)
            
            self.inboxMessagesURLSession.dataTask(with: request) { data, response, error in
                if let error = error {
                    onError("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let responseData = data, let httpResponse = response as? HTTPURLResponse {
                    let responseBody = String(decoding: responseData, as: UTF8.self)
                    
                    switch httpResponse.statusCode {
                    case 200:
                        onComplete(responseBody)
                    case 401:
                        SDKSecurity.shared.updateJWTwithCallbacks(onComplete: { response in
                            self.getInboxMessages(urlKey: urlKey, onComplete: onComplete, onError: onError)
                        }, onError: { error in
                            onError(error)
                        })
                    default:
                        let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        let error = "Fetching inbox messages failed. Error: [\(message)]"
                        
                        onError(error)
                    }
                } else {
                    let error = "Error: [Inbox messages payload is absent]"
                    onError(error)
                }
            }.resume()
        }
    }
}
