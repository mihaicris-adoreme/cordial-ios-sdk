//
//  SendContactOrderRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class SendContactOrderRequest: NSObject, NSCoding {

    let mcID: String?
    let order: Order
    
    enum Key: String {
        case mcID = "mcID"
        case order = "order"
    }
    
    init(mcID: String?, order: Order) {
        self.mcID = mcID
        self.order = order
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.order, forKey: Key.order.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String?
        let order = aDecoder.decodeObject(forKey: Key.order.rawValue) as! Order
        
        self.init(mcID: mcID, order: order)
    }
}
