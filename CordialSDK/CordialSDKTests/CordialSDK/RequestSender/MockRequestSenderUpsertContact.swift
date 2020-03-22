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
    
    let sdkTests = CordialSDKTests()
    
    var testContactAttributes = Dictionary<String, AttributeValue>()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            let json = jsonArray.first! as! [String: AnyObject]
            
            let attributesJSON = json["attributes"] as! [String: AnyObject]
            
            let stringValueFromJSON = attributesJSON["StringValue"] as! String
            let booleanValueFromJSON = attributesJSON["BooleanValue"] as! Bool
            let numericValueFromJSON = attributesJSON["NumericValue"] as! Double
            let arrayValueFromJSON = attributesJSON["ArrayValue"] as! [String]
            let dateValueFromJSON = DateFormatter().getDateFromTimestamp(timestamp: attributesJSON["DateValue"] as! String)!
            
            let stringValue = self.testContactAttributes["StringValue"] as! StringValue
            let booleanValue = self.testContactAttributes["BooleanValue"] as! BooleanValue
            let numericValue = self.testContactAttributes["NumericValue"] as! NumericValue
            let arrayValue = self.testContactAttributes["ArrayValue"] as! ArrayValue
            let dateValue = self.testContactAttributes["DateValue"] as! DateValue
            
            XCTAssertEqual(stringValueFromJSON, stringValue.value, "String value is invalid")
            XCTAssertEqual(booleanValueFromJSON, booleanValue.value, "Boolean value is invalid")
            XCTAssertEqual(numericValueFromJSON, numericValue.value, "Numeric value is invalid")
            XCTAssertEqual(arrayValueFromJSON, arrayValue.value, "Array value is invalid")
            XCTAssertEqual(Int(dateValueFromJSON.timeIntervalSince1970), Int(dateValue.value.timeIntervalSince1970), "Date value is invalid")
            
            self.isVerified = true
        }
    }
    
}

