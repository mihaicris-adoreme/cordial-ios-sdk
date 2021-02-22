//
//  MockRequestSenderRemoteNotificationStatus.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 27.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderRemoteNotificationStatus: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let status = self.sdkTests.testCase.getPushNotificationStatus() {
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                let json = jsonArray.first! as! [String: AnyObject]
                
                XCTAssertEqual(status, json["status"] as! String, "Push notification status don't match")
                
                self.isVerified = true
            }
        }
    }
}

