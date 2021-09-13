//
//  MockRequestSenderInAppMessageHasBeenShownDirectDelivery.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 30.07.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInAppMessageHasBeenShownDirectDelivery: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        if let inAppMessagesURL = self.sdkTests.testCase.getInboxMessagesURL(contactKey: self.sdkTests.testPrimaryKey),
           let inAppMessageContentURL = URL(string: "https://cordial.com/in-app-message-content/"),
           let inAppMessagesRequestURL = task.originalRequest?.url {
            
            switch inAppMessagesRequestURL {
            case inAppMessagesURL:
                self.sdkTests.testCase.sendInAppMessagesDataFetchRequestDirectDelivery(task: task)
            case inAppMessageContentURL:
                self.sdkTests.testCase.sendInAppMessageContentDataFetchRequestDirectDelivery(task: task)
            default:
                if let httpBody = task.originalRequest?.httpBody {
                    if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
                        jsonArray.forEach { jsonAnyObject in
                            let json = jsonAnyObject as! [String: AnyObject]
                            
                            XCTAssertEqual(json["event"] as! String, self.sdkTests.testCase.getEventNameInAppMessageShown(), "Event name don't match")
                            
                            self.isVerified = true
                        }
                    }
                }
            }
        }
    }
}
