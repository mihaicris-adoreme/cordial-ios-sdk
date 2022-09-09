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
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            let json = jsonArray.first! as! [String: AnyObject]
            
            let attributesJSON = json["attributes"] as! [String: AnyObject]
            
            let stringValueFromJSON = attributesJSON["StringKey"] as! String
            let booleanValueFromJSON = attributesJSON["BooleanKey"] as! Bool
            let numericValueFromJSON = attributesJSON["NumericKey"] as! Double
            let arrayValueFromJSON = attributesJSON["ArrayKey"] as! [String]
            let dateValueFromJSON = CordialDateFormatter().getDateFromTimestamp(timestamp: attributesJSON["DateKey"] as! String)!
            let geoValueFromJSON = attributesJSON["GeoKey"] as! [String: String]
            
            let stringValue = self.testContactAttributes["StringKey"] as! StringValue
            let booleanValue = self.testContactAttributes["BooleanKey"] as! BooleanValue
            let numericValue = self.testContactAttributes["NumericKey"] as! NumericValue
            let arrayValue = self.testContactAttributes["ArrayKey"] as! ArrayValue
            let dateValue = self.testContactAttributes["DateKey"] as! DateValue
            let geoValue = self.testContactAttributes["GeoKey"] as! GeoValue
            
            XCTAssertEqual(stringValueFromJSON, stringValue.value, "String value is invalid")
            XCTAssertEqual(booleanValueFromJSON, booleanValue.value, "Boolean value is invalid")
            XCTAssertEqual(numericValueFromJSON, numericValue.value, "Numeric value is invalid")
            XCTAssertEqual(arrayValueFromJSON, arrayValue.value, "Array value is invalid")
            XCTAssertEqual(Int(dateValueFromJSON.timeIntervalSince1970), Int(dateValue.value!.timeIntervalSince1970), "Date value is invalid")
            XCTAssertEqual(geoValueFromJSON["city"], geoValue.getCity(), "Geo city value is invalid")
            XCTAssertEqual(geoValueFromJSON["country"], geoValue.getCountry(), "Geo country value is invalid")
            XCTAssertEqual(geoValueFromJSON["postal_code"], geoValue.getPostalCode(), "Geo postal code value is invalid")
            XCTAssertEqual(geoValueFromJSON["state"], geoValue.getState(), "Geo state value is invalid")
            XCTAssertEqual(geoValueFromJSON["street_address"], geoValue.getStreetAddress(), "Geo street address value is invalid")
            XCTAssertEqual(geoValueFromJSON["street_address2"], geoValue.getStreetAddress(), "Geo street address 2 value is invalid")
            XCTAssertEqual(geoValueFromJSON["tz"], geoValue.getTimeZone(), "Geo time zone value is invalid")
            
            self.isVerified = true
        }
    }
}
