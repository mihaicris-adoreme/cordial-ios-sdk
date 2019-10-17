//
//  UpsertContactCartRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class UpsertContactCartRequest: NSObject, NSCoding {

    let requestID: String
    var primaryKey: String?
    let cartItems: [CartItem]
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case requestID = "requestID"
        case cartItems = "cartItems"
    }
    
    @objc public init(cartItems: [CartItem]) {
        self.requestID = UUID().uuidString
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.cartItems = cartItems
    }
    
    private init(requestID: String, cartItems: [CartItem]) {
        self.requestID = requestID
        self.primaryKey = cordialAPI.getContactPrimaryKey()
        self.cartItems = cartItems
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.cartItems, forKey: Key.cartItems.rawValue)
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as! String
        let cartItems = aDecoder.decodeObject(forKey: Key.cartItems.rawValue) as! [CartItem]
        
        self.init(requestID: requestID, cartItems: cartItems)
    }
}
