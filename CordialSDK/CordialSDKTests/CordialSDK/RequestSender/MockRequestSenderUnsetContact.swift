//
//  MockRequestSenderUnsetContact.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 03.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUnsetContact: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let request = task.originalRequest, let httpBody = request.httpBody {
                        
            if let json = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject] {
                
                XCTAssertEqual(json["primaryKey"] as! String, self.sdkTests.testPrimaryKey, "Primary keys don't match")
                
                self.isVerified = true
            }
        }
    }
    
}
