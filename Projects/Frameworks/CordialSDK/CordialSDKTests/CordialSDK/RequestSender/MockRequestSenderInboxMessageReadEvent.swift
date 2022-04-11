//
//  MockRequestSenderInboxMessageReadEvent.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInboxMessageReadEvent: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            let json = jsonArray.first! as! [String: AnyObject]
            
            XCTAssertEqual(json["event"] as! String, self.sdkTests.testCase.getEventNameInboxMessageRead(), "Events don't match")
            XCTAssertEqual(json["mcID"] as! String, self.sdkTests.testMcID, "mcIDs don't match")
            
            self.isVerified = true
        }
    }
}
