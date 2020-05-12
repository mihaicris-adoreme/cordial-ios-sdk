//
//  MockRequestSenderUpsertContactCartReachability.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 12.05.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderUpsertContactCartReachability: RequestSender {
    
    var isVerified = false
    
    let sdkTests = CordialSDKTests()
    
    var cartItemIDs = [String]()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                let cartItems = json["cartitems"] as! [AnyObject]
                
                cartItems.forEach { cartItemAnyObject in
                    let cartItem = cartItemAnyObject as! [String: AnyObject]
                    
                    if !cartItemIDs.contains(cartItem["productID"] as! String) {
                        XCTAssert(false, "Cart item don't match")
                    }
                    
                    self.isVerified = true
                }
            }
        }
    }
}
