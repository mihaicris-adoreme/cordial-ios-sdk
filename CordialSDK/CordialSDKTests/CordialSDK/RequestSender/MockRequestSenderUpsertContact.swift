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
        if let request = task.originalRequest, let httpBody = request.httpBody {
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                jsonArray.forEach { jsonObject in
                    guard let json = jsonObject as? [String: AnyObject] else {
                        return
                    }
                    
                    if let attributesJSON = json["attributes"] as? [String: AnyObject] {
                        let attributesKeys = self.sdkTests.testContactAttributes.keys
                        
                        var testCount = 0
                        attributesKeys.forEach { key in
                            if let attribute = attributesJSON[key] as? String, attribute == self.sdkTests.testContactAttributes[key] {
                                testCount+=1
                            }
                        }
                        
                        if self.sdkTests.testContactAttributes.count != testCount {
                            XCTAssert(false)
                        }
                    }
                }
            }
            
            self.isVerified = true
        }
    }
    
}

