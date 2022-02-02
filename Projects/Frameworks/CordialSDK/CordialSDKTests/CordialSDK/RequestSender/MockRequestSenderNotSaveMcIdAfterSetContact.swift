//
//  MockRequestSenderNotSaveMcIdAfterSetContact.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 05.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderNotSaveMcIdAfterSetContact: RequestSender {
    
    var isVerified = false
    
    override func sendRequest(task: URLSessionDownloadTask) {
        XCTAssertEqual(CordialAPI().getCurrentMcID(), nil, "mcIDs don't match")
        
        self.isVerified = true
    }
}
