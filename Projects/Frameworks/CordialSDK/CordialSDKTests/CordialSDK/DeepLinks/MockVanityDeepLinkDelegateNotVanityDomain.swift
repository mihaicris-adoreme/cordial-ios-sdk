//
//  MockVanityDeepLinkDelegateNotVanityDomain.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 15.02.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockVanityDeepLinkDelegateNotVanityDomain: CordialDeepLinksDelegate {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        
        let url = deepLink.url
        
        self.testDeepLinks(url: url, fallbackURL: fallbackURL)
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, scene: UIScene, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        
        let url = deepLink.url
        
        self.testDeepLinks(url: url, fallbackURL: fallbackURL)
    }
    
    private func testDeepLinks(url: URL, fallbackURL: URL?) {
        XCTAssertEqual(url.absoluteString, self.sdkTests.validStringURL, "DeepLinkURL keys don't match")
        
        self.isVerified = true
    }
}
