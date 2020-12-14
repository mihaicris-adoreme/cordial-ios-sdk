//
//  MockRequestSenderInboxMessagesMarkReadUnread.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 14.12.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class MockRequestSenderInboxMessagesMarkReadUnread: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        
        if let inboxMessagesMarkReadUnreadURL = self.sdkTests.testCase.getInboxMessagesMarkReadUnreadURL(),
           let inboxMessagesMarkReadUnreadRequestURL = task.originalRequest?.url,
           inboxMessagesMarkReadUnreadURL == inboxMessagesMarkReadUnreadRequestURL {
            
            self.isVerified = true
        } else {
            self.isVerified = false
        }
    }
}
