//
//  MockRequestSenderSendContactOrderTwoOrders.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 02.06.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import XCTest
import CordialSDK

class MockRequestSenderSendContactOrderTwoOrders: RequestSender {
    
    var isVerified = false
    
    var orderID_1 = String()
    var orderID_2 = String()
    
    var isFirstOrder = true
    
    override func sendRequest(task: URLSessionDownloadTask) {
        if let httpBody = task.originalRequest?.httpBody,
           let jsonArray = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [AnyObject] {
            
            jsonArray.forEach { jsonAnyObject in
                let json = jsonAnyObject as! [String: AnyObject]
                
                if let jsonOrder = json["order"] {
                    let jsonOrderID = jsonOrder["orderID"] as AnyObject as! String
                    
                    if self.isFirstOrder {
                        XCTAssertEqual(jsonOrderID, self.orderID_1, "Order ID don't match")
                        
                        self.isFirstOrder = false
                    } else {
                        XCTAssertEqual(jsonOrderID, self.orderID_2, "Order ID don't match")
                        
                        self.isVerified = true
                    }
                }
            }
        }
    }
}
