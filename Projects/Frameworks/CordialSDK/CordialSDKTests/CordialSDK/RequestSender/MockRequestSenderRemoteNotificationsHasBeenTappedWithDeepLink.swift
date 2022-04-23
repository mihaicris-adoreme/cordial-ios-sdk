//
//  MockRequestSenderRemoteNotificationsHasBeenTappedWithDeepLink.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 03.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderRemoteNotificationsHasBeenTappedWithDeepLink: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            jsonArray.forEach { json in
                if let jsonDicrionary = json as? [String: Any],
                   let mcID = jsonDicrionary["mcID"] as? String,
                   let event = jsonDicrionary["event"] as? String,
                   event == self.sdkTests.testCase.getEventNameDeepLinkOpen() {
                    
                    XCTAssertEqual(mcID, self.sdkTests.testMcID, "mcIDs don't match")
                    
                    self.isVerified = true
                }
            }
        }
    }
    
}
