//
//  MockRequestSenderInAppMessageExpirationTime.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 11.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageExpirationTime: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let inAppMessageURL = self.sdkTests.testCase.getInAppMessageURL(mcID: self.sdkTests.testMcID),
            let inAppMessageRequestURL = task.originalRequest?.url,
            inAppMessageURL == inAppMessageRequestURL {
            
            self.sdkTests.testCase.sendInAppMessageDataFetchRequestSilentPushes(task: task)
            
            self.isVerified = true
        } else {
            self.isVerified = false
        }
    }
}
