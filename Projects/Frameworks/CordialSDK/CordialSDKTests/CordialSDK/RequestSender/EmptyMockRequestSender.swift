//
//  EmptyMockRequestSender.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 05.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class EmptyMockRequestSender: RequestSender {
    
    override func sendRequest(task: URLSessionDownloadTask) {
        // do nothing
    }
}
