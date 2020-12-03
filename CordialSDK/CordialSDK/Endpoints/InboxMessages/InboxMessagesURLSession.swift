//
//  InboxMessagesURLSession.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesURLSession: NSObject, URLSessionDelegate {
    
    lazy var session: URLSessionProtocol = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
}
