//
//  CordialSDKTestsHelper.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 24.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class CordialSDKTestsHelper {
    
    let sdkTests = CordialSDKTests()
    
    func setContactValidation(httpBody: Data) {
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            jsonArray.forEach { jsonObject in
                guard let json = jsonObject as? [String: AnyObject] else {
                    return
                }
                
                if let primaryKey = json["primaryKey"] as? String, primaryKey != self.sdkTests.testPrimaryKey {
                    XCTAssert(false)
                }
                
                if let deviceId = json["deviceId"] as? String, deviceId != self.sdkTests.testCase.getDeviceIdentifier() {
                    XCTAssert(false)
                }
                
                if let status = json["status"] as? String, status != self.sdkTests.testCase.getPushNotificationDisallowStatus() {
                    XCTAssert(false)
                }
            }
        }
    }
    
}
