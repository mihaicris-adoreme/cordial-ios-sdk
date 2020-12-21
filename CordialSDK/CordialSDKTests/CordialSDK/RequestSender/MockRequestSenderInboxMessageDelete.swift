//
//  MockRequestSenderInboxMessageDelete.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 14.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInboxMessageDelete: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var contactKey = String()
    var mcID = String()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        if let inboxMessageURL = self.sdkTests.testCase.getInboxMessageURL(contactKey: contactKey, mcID: mcID),
           let inboxMessageRequestURL = task.originalRequest?.url,
           inboxMessageURL == inboxMessageRequestURL {
            
            self.isVerified = true
        } else {
            self.isVerified = false
        }
    }
}
