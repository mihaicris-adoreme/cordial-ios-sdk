//
//  MockRequestSenderInAppMessageHasBeenShownTwoTimes.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 25.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageHasBeenShownTwoTimes: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var testMcID_2 = String()

    var isFirstInAppMessage = true
    
    override init() {
        self.testMcID_2 = "\(self.sdkTests.testMcID)_2"
    }
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let url = task.originalRequest?.url {
            switch url {
            case self.sdkTests.testCase.getInAppMessageURL(mcID: self.sdkTests.testMcID):
                self.sdkTests.testCase.sendInAppMessageDataFetchRequestSilentPushes(task: task)
            case self.sdkTests.testCase.getInAppMessageURL(mcID: self.testMcID_2):
                self.sdkTests.testCase.sendInAppMessageDataFetchRequestSilentPushes(task: task)
            default:
                if let httpBody = task.originalRequest?.httpBody,
                   let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                    
                    jsonArray.forEach { jsonAnyObject in
                        let json = jsonAnyObject as! [String: AnyObject]
                        
                        XCTAssertEqual(json["event"] as! String, self.sdkTests.testCase.getEventNameInAppMessageShown(), "Event name don't match")
                        
                        if isFirstInAppMessage {
                            isFirstInAppMessage = false
                        } else {
                            self.isVerified = true
                        }
                    }
                }
            }
        }
    }
}
