//
//  MockRequestSenderInAppMessageHasBeenShown.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 24.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageHasBeenShown: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let inAppMessageURL = self.sdkTests.testCase.getInAppMessageURL(mcID: self.sdkTests.testMcID),
            let inAppMessageRequestURL = task.originalRequest?.url,
            inAppMessageURL == inAppMessageRequestURL {
            
            self.sdkTests.testCase.sendInAppMessageDataFetchRequestSilentPushes(task: task)
        } else if let httpBody = task.originalRequest?.httpBody,
                  let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                XCTAssertEqual(json["event"] as! String, self.sdkTests.testCase.getEventNameInAppMessageShown(), "Event name don't match")
                
                self.isVerified = true
            }
        }
    }
}
