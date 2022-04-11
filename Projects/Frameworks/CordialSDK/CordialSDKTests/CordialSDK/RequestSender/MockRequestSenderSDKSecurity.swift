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
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                let json = jsonArray.first! as! [String: AnyObject]
                
                XCTAssertEqual(json["primaryKey"] as! String, self.sdkTests.testPrimaryKey, "Primary keys don't match")
                XCTAssertEqual(json["deviceId"] as! String, self.sdkTests.testCase.getDeviceIdentifier(), "Device ids don't match")
                XCTAssertEqual(json["status"] as! String, self.sdkTests.testCase.getPushNotificationDisallowStatus(), "Statuses keys don't match")
            } else {
                XCTAssert(false, "httpBody don't array json")
            }
            
            self.isVerified = true
            
        } else {
            self.sdkTests.testCase.notValidJWT(task: task)
        }
    }
}
