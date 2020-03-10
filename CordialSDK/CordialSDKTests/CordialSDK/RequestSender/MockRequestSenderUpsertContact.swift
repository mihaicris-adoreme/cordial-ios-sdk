//
//  MockRequestSenderUpsertContact.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUpsertContact: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            let attributesJSON = json["attributes"] as! [String: AnyObject]
            
            let attributesKeys = self.sdkTests.testContactAttributes.keys
            
            var testCount = 0
            attributesKeys.forEach { key in
                if let attribute = attributesJSON[key] as? String, attribute == self.sdkTests.testContactAttributes[key] {
                    testCount+=1
                }
            }
            
            XCTAssertEqual(self.sdkTests.testContactAttributes.count, testCount, "Contact attributes don't match")
            
            self.isVerified = true
        }
    }
    
}

