//
//  MockRequestSenderIfEventRequestHasInvalidEvent.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 16.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderIfEventRequestHasInvalidEvent: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var validEventNames = [String]()
    
    var invalidEventName: String!
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        let jsonString = String(decoding: httpBody, as: UTF8.self)
        
        if jsonString.contains(self.invalidEventName) {
            self.sdkTests.testCase.sendInvalidEventRequest(task: task, invalidEventName: self.invalidEventName)
        } else {
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                jsonArray.forEach { jsonAnyObject in
                    let json = jsonAnyObject as! [String: AnyObject]
                    
                    if !self.validEventNames.contains(json["event"] as! String) {
                        XCTAssert(false, "Event don't match")
                    }
                    
                    self.isVerified = true
                }
            }
        }
    }
    
}
