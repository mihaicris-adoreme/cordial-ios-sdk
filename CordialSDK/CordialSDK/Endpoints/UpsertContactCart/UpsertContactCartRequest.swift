//
//  UpsertContactCartRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class UpsertContactCartRequest: NSObject, NSCoding {

    let deviceID: String
    var primaryKey: String?
    let cartItems: [CartItem]
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case cartItems = "cartItems"
    }
    
    public init(cartItems: [CartItem]) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.cartItems = cartItems
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.cartItems, forKey: Key.cartItems.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let cartItems = aDecoder.decodeObject(forKey: Key.cartItems.rawValue) as! [CartItem]
        
        self.init(cartItems: cartItems)
    }
}
