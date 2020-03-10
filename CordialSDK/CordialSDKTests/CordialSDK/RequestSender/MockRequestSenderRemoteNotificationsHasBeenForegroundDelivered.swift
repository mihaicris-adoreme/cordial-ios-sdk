//
//  MockRequestSenderRemoteNotificationsHasBeenForegroundDelivered.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderRemoteNotificationsHasBeenForegroundDelivered: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            XCTAssertEqual(json["event"] as! String, self.sdkTests.testCase.getEventNamePushNotificationForegroundDelivered(), "Events don't match")
//            XCTAssertEqual(json["mcID"] as! String, self.sdkTests.testMcId, "mcIDs don't match") // TMP COMMENT NEED TO UNCOMMENT AFTER MERGE BRANCH TO `remove_mcID_refactoring`
            
            self.isVerified = true
        }
    }
    
}
