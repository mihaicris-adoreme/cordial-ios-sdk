//
//  RequestSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc open class RequestSender: NSObject {
    
    @objc open func sendRequest(task: URLSessionDownloadTask) {
        task.resume()
    }
    
}
