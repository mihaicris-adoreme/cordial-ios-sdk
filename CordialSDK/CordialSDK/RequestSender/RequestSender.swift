//
//  RequestSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

open class RequestSender: NSObject {
    
    open func sendRequest(task: URLSessionDownloadTask) {
        task.resume()
    }
    
}
