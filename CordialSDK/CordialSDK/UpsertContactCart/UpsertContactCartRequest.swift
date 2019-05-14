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
        case primaryKey = "primaryKey"
        case cartItems = "cartItems"
    }
    
    public init(cartItems: [CartItem]) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        self.cartItems = cartItems
    }
    
    private init(primaryKey: String?, cartItems: [CartItem]) {  
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = primaryKey
        self.cartItems = cartItems
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(cartItems, forKey: Key.cartItems.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
        let cartItems = aDecoder.decodeObject(forKey: Key.cartItems.rawValue) as! [CartItem]
        
        self.init(primaryKey: primaryKey, cartItems: cartItems)
    }
}
