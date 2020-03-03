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
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            switch json["event"] as! String {
            case self.sdkTests.testCase.getEventNamePushNotificationTap():
                XCTAssertEqual(json["mcID"] as! String, self.sdkTests.testMcId, "mcIDs don't match")
            case self.sdkTests.testCase.getEventNameDeepLinkOpen():
                XCTAssertEqual(json["mcID"] as! String, self.sdkTests.testMcId, "mcIDs don't match")
                
                self.isVerified = true
            default:
                XCTAssert(false, "Events don't match")
            }
        }
    }
    
}
