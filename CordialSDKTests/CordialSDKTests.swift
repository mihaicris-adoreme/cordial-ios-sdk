//
//  CordialSDKTests.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 3/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import XCTest
@testable import CordialSDK

class CordialSDKTests: XCTestCase {
    
    override func setUp() {
        CordialApiConfiguration.shared.initWithApiKey(apiKey: "NWM3ZDM2Y2U3ZGI4MjliYTY1ZDgyNDlkLTdOV3g2RlE0bW9BV1JKZXFGUG9waU9ZcGlHYU5KblR3Og==")
    }
    
    func initCordialAPIWithContactPrimaryKey(completionHadler: @escaping (CordialAPI) -> Void) -> Void {
        let cordialAPI = CordialAPI()
        let primaryKey = "yan.malinovsky@gmail.com"
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey, attributes: nil, list: nil)
        cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest,
            onSuccess: { result in
                completionHadler(cordialAPI)
            },
            onError: { error in
                XCTFail()
            }
        )
    }

    func testCreateContact() {
        let cordialAPI = CordialAPI()
        let primaryKey = "yan.malinovsky+\(NSDate().timeIntervalSince1970)@gmail.com"
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Expectation for a background task")
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey, attributes: nil, list: nil)
        cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest,
            onSuccess: { result in
                XCTAssertEqual(result.status, .CREATED)
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectation.fulfill()
            },
            onError: { error in
                XCTFail()
            }
        )
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCreateContactWithInvalidEmailFails() {
        let cordialAPI = CordialAPI()
        let primaryKey = "Invalid email"
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Expectation for a background task")
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey, attributes: nil, list: nil)
        cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest,
            onSuccess: { result in
                XCTFail()
            },
            onError: { error in
                XCTAssertEqual(nil, error.statusCode)
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectation.fulfill()
            }
        )
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }

    func testUpdateContact() {
        let cordialAPI = CordialAPI()
        let primaryKey = "yan.malinovsky@gmail.com"
        
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Expectation for a background task")
        
        let upsertContactRequest = UpsertContactRequest(primaryKey: primaryKey, attributes: nil, list: nil)
        cordialAPI.upsertContact(upsertContactRequest: upsertContactRequest,
            onSuccess: { result in
                XCTAssertEqual(result.status, .UPDATED)
                // Fulfill the expectation to indicate that the background task has finished successfully.
                expectation.fulfill()
            },
            onError: { error in
                XCTFail()
            }
        )
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }

    func testSendCustomEvent() {
        // Create an expectation for a background download task.
        let expectation = XCTestExpectation(description: "Expectation for a background task")
        
        initCordialAPIWithContactPrimaryKey { cordialAPI in
            if let deviceID = cordialAPI.getDeviceIdentifier {
                let accountKey = cordialAPI.getAccountKey()
                let eventName = "TestEventName"
                let timestamp = cordialAPI.getTimestamp()
                
                let sendCustomEventRequest = SendCustomEventRequest(accountKey: accountKey, deviceID: deviceID, eventName: eventName, timestamp: timestamp, properties: nil)
                cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest,
                    onSuccess: { result in
                        XCTAssertEqual(result.status, .SUCCESS)
                        // Fulfill the expectation to indicate that the background task has finished successfully.
                        expectation.fulfill()
                    },
                    onError: { error in
                        XCTFail()
                    }
                )
            }
        }
        
        // Wait until the expectation is fulfilled, with a timeout of 10 seconds.
        wait(for: [expectation], timeout: 10.0)
    }
    
}
