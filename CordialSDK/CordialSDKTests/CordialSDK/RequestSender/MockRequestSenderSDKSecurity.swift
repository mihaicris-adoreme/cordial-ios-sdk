//
//  MockRequestSenderSDKSecurity.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//


import XCTest
import CordialSDK

class MockRequestSenderSDKSecurity: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if self.sdkTests.testCase.getCurrentJWT() != self.sdkTests.testJWT, let httpBody = task.originalRequest?.httpBody {
            CordialSDKTestsHelper().setContactValidation(httpBody: httpBody)
            
            self.isVerified = true
            
        } else {
            self.sdkTests.testCase.notValidJWT(task: task)
        }
    }
    
}


