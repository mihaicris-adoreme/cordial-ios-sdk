//
//  MockRequestSenderURLSchemesDeepLinkHasBeenOpen.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 18.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderURLSchemesDeepLinkHasBeenOpen: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            if jsonArray.contains(where: { ($0["event"]?.isEqual(self.sdkTests.testCase.getEventNameDeepLinkOpen()))! }) {
                self.isVerified = true
            }
        }
    }
}
