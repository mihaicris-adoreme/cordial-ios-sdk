//
//  MockRequestSenderSetContactWithoutNotificationToken.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 14.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSetContactWithoutNotificationToken: RequestSender {
    
    var isVerified = false
    
    var isCalled = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        self.isCalled = true
        
        if let request = task.originalRequest, let httpBody = request.httpBody {
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                let json = jsonArray.first! as! [String: AnyObject]
                
                XCTAssertEqual(json["primaryKey"] as! String, self.sdkTests.testPrimaryKey, "Primary keys don't match")
                XCTAssertEqual(json["deviceId"] as! String, self.sdkTests.testCase.getDeviceIdentifier(), "Device ids don't match")
                XCTAssertEqual(json["status"] as! String, self.sdkTests.testCase.getPushNotificationDisallowStatus(), "Statuses keys don't match")
            } else {
                XCTAssert(false, "httpBody don't array json")
            }
            
            self.isVerified = true
        }
    }
    
}

