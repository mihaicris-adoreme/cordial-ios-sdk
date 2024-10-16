//
//  MockRequestSenderInAppMessageManualDismiss.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 07.07.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageManualDismiss: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let inAppMessageURL = self.sdkTests.testCase.getInAppMessageURL(mcID: self.sdkTests.testMcID),
            let inAppMessageRequestURL = task.originalRequest?.url,
            inAppMessageURL == inAppMessageRequestURL {
            
            self.sdkTests.testCase.sendInAppMessageDataFetchRequestSilentPushes(task: task)
        } else if let httpBody = task.originalRequest?.httpBody,
                  let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                let event = json["event"] as! String
                
                if event == self.sdkTests.testCase.getEventNameInAppMessageManualRemove() {
                    self.isVerified = true
                }
            }
        }
    }
}
