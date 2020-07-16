//
//  MockRequestSenderInAppMessageUserClickedInAppMessageActionButton.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 11.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageUserClickedInAppMessageActionButton: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var isInAppMessageHasBeenShown = false
    
    var eventName = String()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        if let inAppMessageURL = self.sdkTests.testCase.getInAppMessageURL(mcID: self.sdkTests.testMcId),
            let inAppMessageRequestURL = task.originalRequest?.url,
            inAppMessageURL == inAppMessageRequestURL {
            
            self.sdkTests.testCase.sendInAppMessageDataFetchRequest(task: task)
        } else {
            let httpBody = task.originalRequest!.httpBody!
            
            if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                jsonArray.forEach { jsonAnyObject in
                    let json = jsonAnyObject as! [String: AnyObject]
                    
                    let event = json["event"] as! String
                    
                    switch event {
                    case self.sdkTests.testCase.getEventNameInAppMessageShown():
                        isInAppMessageHasBeenShown = true
                    case self.eventName:
                        if isInAppMessageHasBeenShown {
                            self.isVerified = true
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}
