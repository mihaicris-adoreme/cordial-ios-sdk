//
//  MockRequestSenderRemoteNotificationsDeviceToken.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderRemoteNotificationsDeviceToken: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        let jsonString = String(decoding: httpBody, as: UTF8.self)
        
        if let deviceToken = Data(base64Encoded: self.sdkTests.testDeviceToken) {
            XCTAssertNotNil(jsonString.range(of: self.sdkTests.testCase.getPreparedRemoteNotificationsDeviceToken(deviceToken: deviceToken)))
            
            self.isVerified = true
        }
    }
}

