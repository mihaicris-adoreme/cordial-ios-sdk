//
//  MockRequestSenderInboxMessagesMarkUnreadInvalidMcID.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 16.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderInboxMessagesMarkUnreadInvalidMcID: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var invalidMcID = String()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        let httpBody = task.originalRequest!.httpBody!
        
        let jsonString = String(decoding: httpBody, as: UTF8.self)
        
        if let inboxMessagesMarkReadUnreadURL = self.sdkTests.testCase.getInboxMessagesMarkReadUnreadURL(),
           let inboxMessagesMarkReadUnreadRequestURL = task.originalRequest?.url,
           inboxMessagesMarkReadUnreadURL == inboxMessagesMarkReadUnreadRequestURL {
            
            if jsonString.contains(self.invalidMcID) {
                self.sdkTests.testCase.sendInvalidInboxMessagesMarkReadUnreadRequest(type: "markAsUnReadIds", mcID: self.invalidMcID, task: task)
            } else {
                self.isVerified = true
            }
        } else {
            self.isVerified = false
        }
    }
}
