//
//  UpsertContactCartRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class UpsertContactCartRequest: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding = true
    
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
    
    func encode(with coder: NSCoder) {
        coder.encode(self.requestID, forKey: Key.requestID.rawValue)
        coder.encode(self.cartItems, forKey: Key.cartItems.rawValue)
        coder.encode(self.primaryKey, forKey: Key.primaryKey.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        if let requestID = coder.decodeObject(forKey: Key.requestID.rawValue) as? String,
           let primaryKey = coder.decodeObject(forKey: Key.primaryKey.rawValue) as? String?,
           let cartItems = coder.decodeObject(forKey: Key.cartItems.rawValue) as? [CartItem] {
            
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
