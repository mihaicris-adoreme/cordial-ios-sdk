//
//  SendContactOrderRequest.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public class SendContactOrderRequest: NSObject, NSCoding {

    let deviceID: String
    var primaryKey: String?
    let order: Order
    
    let cordialAPI = CordialAPI()
    
    enum Key: String {
        case primaryKey = "primaryKey"
        case order = "order"
    }
    
    public init(order: Order) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = UserDefaults.standard.string(forKey: API.USER_DEFAULTS_KEY_FOR_PRIMARY_KEY)
        self.order = order
    }
    
    private init(primaryKey: String?, order: Order) {
        self.deviceID = cordialAPI.getDeviceIdentifier()
        self.primaryKey = primaryKey
        self.order = order
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(primaryKey, forKey: Key.primaryKey.rawValue)
        aCoder.encode(order, forKey: Key.order.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let primaryKey = aDecoder.decodeObject(forKey: Key.primaryKey.rawValue) as! String?
        let order = aDecoder.decodeObject(forKey: Key.order.rawValue) as! Order
        
        self.init(primaryKey: primaryKey, order: order)
    }
}
