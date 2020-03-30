//
//  MockRequestSenderUpsertContact.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUpsertContact: RequestSender {
    
    var isVerified = false
    
    var testContactAttributes = Dictionary<String, AttributeValue>()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            let attributesJSON = json["attributes"] as! [String: AnyObject]
            
            let stringValueAttributes = attributesJSON["StringKey"] as! String
            let booleanValueAttributes = attributesJSON["BooleanKey"] as! Bool
            let numericValueAttributes = attributesJSON["NumericKey"] as! Double
            let arrayValueAttributes = attributesJSON["ArrayKey"] as! [String]
            
            let stringValueContactAttributes = self.testContactAttributes["StringKey"] as! StringValue
            let booleanValueContactAttributes = self.testContactAttributes["BooleanKey"] as! BooleanValue
            let numericValueContactAttributes = self.testContactAttributes["NumericKey"] as! NumericValue
            let arrayValueContactAttributes = self.testContactAttributes["ArrayKey"] as! ArrayValue
            
            XCTAssertEqual(stringValueAttributes, stringValueContactAttributes.value, "String value is invalid")
            XCTAssertEqual(booleanValueAttributes, booleanValueContactAttributes.value, "Boolean value is invalid")
            XCTAssertEqual(numericValueAttributes, numericValueContactAttributes.value, "Numeric value is invalid")
            XCTAssertEqual(arrayValueAttributes, arrayValueContactAttributes.value, "Array value is invalid")
            
            self.isVerified = true
        }
    }
    
}

