//
//  MockRequestSenderUpsertContactCartEmptyCart.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 12.05.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUpsertContactCartEmptyCart: RequestSender {
    
    var isVerified = false
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                let cartItems = json["cartitems"] as! [AnyObject]
                
                XCTAssertEqual(cartItems.count, 0, "Cart items count don't match")
                
                self.isVerified = true
            }
        }
    }
}
