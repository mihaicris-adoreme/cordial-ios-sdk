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
        if let request = task.originalRequest, let httpBody = request.httpBody {
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                jsonArray.forEach { jsonObject in
                    guard let json = jsonObject as? [String: AnyObject] else {
                        return
                    }
                    
                    if let eventName = json["event"] as? String, eventName != self.sdkTests.testCase.getEventNamePushNotificationTap() {
                        XCTAssert(false)
                    }
                }
            }
            
            self.isVerified = true
        }
    }
    
}
