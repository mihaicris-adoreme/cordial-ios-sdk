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
           let inAppMessagesRequestURL = task.originalRequest?.url,
           inAppMessagesURL == inAppMessagesRequestURL {
            
            // TODO
            self.isVerified = true // TMP
            
        } else {
            // TODO
        }
        
    }
}
