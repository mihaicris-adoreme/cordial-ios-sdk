//
//  MockRequestSenderSetContact.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSetContact: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let request = task.originalRequest, let httpBody = request.httpBody {
            CordialSDKTestsHelper().setContactValidation(httpBody: httpBody)
            
            self.isVerified = true
        }
    }
    
}
