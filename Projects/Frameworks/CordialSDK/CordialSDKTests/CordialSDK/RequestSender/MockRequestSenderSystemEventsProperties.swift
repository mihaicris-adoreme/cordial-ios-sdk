//
//  MockRequestSenderSystemEventsProperties.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 13.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSystemEventsProperties: RequestSender {
    
    var isVerified = false
    
    var systemEventsProperties = Dictionary<String, String>()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            let json = jsonArray.first! as! [String: AnyObject]
            
            let properties = json["properties"] as! Dictionary<String, String>
            let propertiesKeys = properties.keys
            
            propertiesKeys.forEach { key in
                XCTAssertEqual(properties[key], self.systemEventsProperties[key], "System events property don't match")
            }
            
            self.isVerified = true
        }
    }
}
