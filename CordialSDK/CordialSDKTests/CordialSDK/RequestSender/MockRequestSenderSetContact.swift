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
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                jsonArray.forEach { jsonObject in
                    guard let json = jsonObject as? [String: AnyObject] else {
                        return
                    }
                    
                    if let primaryKey = json["primaryKey"] as? String, primaryKey != self.sdkTests.testPrimaryKey {
                        XCTAssert(false)
                    }
                    
                    if let deviceId = json["deviceId"] as? String, deviceId != self.sdkTests.testCase.getDeviceIdentifier() {
                        XCTAssert(false)
                    }
                    
                    if let status = json["status"] as? String, status != self.sdkTests.testCase.getPushNotificationDisallowStatus() {
                        XCTAssert(false)
                    }
                }
            }
            
            self.isVerified = true
        }
    }
    
}
