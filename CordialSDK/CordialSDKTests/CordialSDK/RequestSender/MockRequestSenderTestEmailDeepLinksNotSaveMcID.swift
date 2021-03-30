//
//  MockRequestSenderTestEmailDeepLinksNotSaveMcID.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 12.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderTestEmailDeepLinksNotSaveMcID: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            if jsonArray.contains(where: {
              ($0["event"]?.isEqual(self.sdkTests.testCase.getEventNameDeepLinkOpen()))! &&
              ($0["mcID"] == nil) }) {
                
                self.isVerified = true
            }
        }
    }
}
