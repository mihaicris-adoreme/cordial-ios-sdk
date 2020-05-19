//
//  MockRequestSenderUserAgent.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 14.05.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUserAgent: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        let userAgent = task.originalRequest!.allHTTPHeaderFields!["User-Agent"]
        XCTAssertEqual(self.sdkTests.testCase.getUserAgent(), userAgent, "User-Agent don't match")
        
        self.isVerified = true
    }
    
}
