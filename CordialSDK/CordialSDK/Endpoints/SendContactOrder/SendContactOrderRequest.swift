//
//  SendContactOrderRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class SendContactOrderRequest: NSObject, NSCoding {

    var primaryKey: String?
    let mcID: String?
    let order: Order
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case mcID = "mcID"
        case order = "order"
    }
    
    @objc public init(order: Order) {
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.mcID = cordialAPI.getCurrentMcID()
        self.order = order
    }
    
    private init(order: Order, mcID: String?) {
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.mcID = mcID
        self.order = order
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.order, forKey: Key.order.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String?
        let order = aDecoder.decodeObject(forKey: Key.order.rawValue) as! Order
        
        self.init(order: order, mcID: mcID)
    }
}
