//
//  MockRequestSenderQtyCachedEventQueue.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 02.02.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderQtyCachedEventQueue: RequestSender {
    
    var isVerified = false
    
    let events = ["test_custom_event_3", "test_custom_event_4", "test_custom_event_5"]
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                if !events.contains(json["event"] as! String) {
                    XCTAssert(false, "Event don't match")
                }
                
                self.isVerified = true
            }
        }
    }
}
