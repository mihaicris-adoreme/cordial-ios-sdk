//
//  MockRequestSenderSaveMcIdIfLoginWithPrimaryKeyInGuestMode.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 05.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSaveMcIdIfLoginWithPrimaryKeyInGuestMode: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        XCTAssertEqual(CordialAPI().getCurrentMcID(), self.sdkTests.testMcId, "mcIDs don't match")
        
        self.isVerified = true
    }
    
}
