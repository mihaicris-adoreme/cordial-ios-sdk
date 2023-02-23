//
//  CordialVanityDeepLinkURLSession.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.01.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class CordialVanityDeepLinkURLSession: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    lazy var session: URLSessionProtocol = {
        let config = URLSessionConfiguration.default
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }
}

