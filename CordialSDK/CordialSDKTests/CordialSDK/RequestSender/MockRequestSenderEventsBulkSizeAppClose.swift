//
//  MockRequestSenderEventsBulkSizeAppClose.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 31.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderEventsBulkSizeAppClose: RequestSender {
    
    var isVerified = false
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            XCTAssertEqual(TestCase().getEventNameAppMovedToBackground(), json["event"] as! String, "Event don't match")
            
            self.isVerified = true
        }
    }
    
}
