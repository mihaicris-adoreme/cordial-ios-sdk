//
//  MockPushNotificationDeepLinkDelegate.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 04.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockPushNotificationDeepLinkDelegate: CordialDeepLinksDelegate {
    
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
        XCTAssertEqual(url.absoluteString, self.sdkTests.testDeepLinkURL, "DeepLinkURL keys don't match")
        XCTAssertEqual(fallbackURL!.absoluteString, self.sdkTests.testDeepLinkFallbackURL, "DeepLinkFallbackURL don't match")
        
        self.isVerified = true
    }
}
