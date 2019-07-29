//
//  SendContactOrderRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactOrderRequest: NSObject, NSCoding {

    let deviceID: String
    var primaryKey: String?
    let order: Order
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case order = "order"
    }
    
    @objc public init(order: Order) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.order = order
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.order, forKey: Key.order.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let order = aDecoder.decodeObject(forKey: Key.order.rawValue) as! Order
        
        self.init(order: order)
    }
}
