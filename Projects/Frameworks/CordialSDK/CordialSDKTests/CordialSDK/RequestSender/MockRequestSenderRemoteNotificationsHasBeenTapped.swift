//
//  MockRequestSenderRemoteNotificationsHasBeenTapped.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderRemoteNotificationsHasBeenTapped: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            let json = jsonArray.first! as! [String: AnyObject]
            
            if json["event"] as! String == self.sdkTests.testCase.getEventNamePushNotificationTap() {
                XCTAssertEqual(json["mcID"] as! String, self.sdkTests.testMcID, "mcIDs don't match")
                
                self.isVerified = true
            }
        }
    }
}
