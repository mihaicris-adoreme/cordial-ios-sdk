//
//  UpsertContactCartRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactCartRequest: NSObject, NSCoding {

    let requestID: String
    let cartItems: [CartItem]
    let primaryKey: String?
    
    var isError = false
    
    enum Key: String {
        case requestID = "requestID"
        case cartItems = "cartItems"
        case primaryKey = "primaryKey"
    }
    
    init(cartItems: [CartItem]) {
        self.requestID = UUID().uuidString
        self.cartItems = cartItems
        self.primaryKey = CordialAPI().getContactPrimaryKey()
    }
    
    private init(requestID: String, cartItems: [CartItem], primaryKey: String?) {
        self.requestID = requestID
        self.cartItems = cartItems
        self.primaryKey = primaryKey
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.requestID, forKey: Key.requestID.rawValue)
        aCoder.encode(self.cartItems, forKey: Key.cartItems.rawValue)
        aCoder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        if let requestID = aDecoder.decodeObject(forKey: Key.requestID.rawValue) as? String,
           let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as? String?,
           let cartItems = aDecoder.decodeObject(forKey: Key.cartItems.rawValue) as? [CartItem] {
            
            var isCartItemError = false
            cartItems.forEach { cartItem in
                if cartItem.isError {
                    isCartItemError = true
                }
            }
            
            if !isCartItemError {
                self.init(requestID: requestID, cartItems: cartItems, primaryKey: primaryKey)
            } else {
                self.init(requestID: String(), cartItems: [CartItem](), primaryKey: nil)
                self.isError = true
            }
        } else {
            self.init(requestID: String(), cartItems: [CartItem](), primaryKey: nil)
            self.isError = true
        }
    }
}
