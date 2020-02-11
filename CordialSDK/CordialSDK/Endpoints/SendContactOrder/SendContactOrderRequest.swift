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
    
    var isError = false
    
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
        if let order = aDecoder.decodeObject(forKey: Key.order.rawValue) as? Order {
            let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String?
            
            self.init(mcID: mcID, order: order)
        } else {
            let address = Address(name: String(), address: String(), city: String(), state: String(), postalCode: String(), country: String())
            let order = Order(orderID: String(), status: String(), storeID: String(), customerID: String(), purchaseDate: Date(), shippingAddress: address, billingAddress: address, items: [CartItem](), tax: nil, shippingAndHandling: nil, properties: nil)
            self.init(mcID: nil, order: order)
            
            self.isError = true
        }
    }
}
