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
        if self.sdkTests.testCase.getCurrentJWT() == self.sdkTests.testJWT { // emulate 401 status behaivor
            self.sdkTests.testCase.emulateUpsertContacts401Status(task: task)
        } else if let httpBody = task.originalRequest?.httpBody {
            CordialSDKTestsHelper().setContactValidation(httpBody: httpBody)
            self.isVerified = true
        }
    }
    
}


