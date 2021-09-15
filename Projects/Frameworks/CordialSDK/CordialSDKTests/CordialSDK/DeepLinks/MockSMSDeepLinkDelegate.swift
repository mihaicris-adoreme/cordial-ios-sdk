//
//  MockSMSDeepLinkDelegate.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 16.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockSMSDeepLinkDelegate: CordialDeepLinksDelegate {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    func openDeepLink(url: URL, fallbackURL: URL?) {
        self.testDeepLinks(url: url, fallbackURL: fallbackURL)
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene) {
        self.testDeepLinks(url: url, fallbackURL: fallbackURL)
    }
    
    private func testDeepLinks(url: URL, fallbackURL: URL?) {
        XCTAssertEqual(url.absoluteString, self.sdkTests.testEmailDeepLinkURL, "DeepLinkURL keys don't match")
        
        self.isVerified = true
    }
}
