//
//  MockRequestSenderEventsBulkSizeTimer.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 30.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderEventsBulkSizeTimer: RequestSender {
    
    var isVerified = false
    
    var event = String()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            let json = jsonArray.first! as! [String: AnyObject]
            
            XCTAssertEqual(self.event, json["event"] as! String, "Event don't match")
            
            self.isVerified = true
        }
    }
    
}
