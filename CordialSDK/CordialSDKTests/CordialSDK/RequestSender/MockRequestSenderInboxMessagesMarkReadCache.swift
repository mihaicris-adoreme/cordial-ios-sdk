//
//  MockRequestSenderInboxMessagesMarkReadCache.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 18.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class MockRequestSenderInboxMessagesMarkReadCache: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let inboxMessagesMarkReadUnreadURL = self.sdkTests.testCase.getInboxMessagesMarkReadUnreadURL(),
           let inboxMessagesMarkReadUnreadRequestURL = task.originalRequest?.url,
           inboxMessagesMarkReadUnreadURL == inboxMessagesMarkReadUnreadRequestURL,
           let json = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject],
           let markAsReadIds = json["markAsReadIds"] as? [String],
           markAsReadIds.contains("\(self.sdkTests.testMcID)_1"),
           markAsReadIds.contains("\(self.sdkTests.testMcID)_2"),
           markAsReadIds.contains("\(self.sdkTests.testMcID)_3"),
           markAsReadIds.contains("\(self.sdkTests.testMcID)_4") {
            
            self.isVerified = true
        } else {
            self.isVerified = false
        }
    }
}
