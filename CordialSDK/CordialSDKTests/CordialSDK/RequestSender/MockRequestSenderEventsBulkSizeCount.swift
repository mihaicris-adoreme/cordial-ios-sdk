//
//  MockRequestSenderEventsBulkSizeCount.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 30.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderEventsBulkSizeCount: RequestSender {
    
    var isVerified = false
    
    var events = [String]()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                if !events.contains(json["event"] as! String) {
                    XCTAssert(false, "Event don't match")
                }
            }
            
            self.isVerified = true
        }
    }
    
}
