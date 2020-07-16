//
//  MockRequestSenderSendContactOrder.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 01.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSendContactOrder: RequestSender {
    
    var isVerified = false
    
    var orderID = String()
    
    override func sendRequest(task: URLSessionDownloadTask) {
        let httpBody = task.originalRequest!.httpBody!
        
        if let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                if let jsonOrder = json["order"] {
                    let jsonOrderID = jsonOrder["orderID"] as AnyObject as! String
                    
                    XCTAssertEqual(jsonOrderID, self.orderID, "Order ID don't match")
                    
                    self.isVerified = true
                }
            }
        }
    }
}
