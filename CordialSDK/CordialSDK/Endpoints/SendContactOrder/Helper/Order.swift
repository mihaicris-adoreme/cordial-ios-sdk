//
//  Order.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/23/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class Order: NSObject, NSCoding {
    
    let orderID: String
    let status: String
    let storeID: String
    let customerID: String
    var purchaseDate: Date
    let shippingAddress: Address
    let billingAddress: Address
    let items: [CartItem]
    let tax: Double?
    let shippingAndHandling: String?
    let properties: Dictionary<String, String>?
    
    enum Key: String {
        case orderID = "orderID"
        case status = "status"
        case storeID = "storeID"
        case customerID = "customerID"
        case purchaseDate = "purchaseDate"
        case shippingAddress = "shippingAddress"
        case billingAddress = "billingAddress"
        case items = "items"
        case tax = "tax"
        case shippingAndHandling = "shippingAndHandling"
        case properties = "properties"
    }
    
    @objc public convenience init(orderID: String, status: String, storeID: String, customerID: String, shippingAddress: Address, billingAddress: Address, items: [CartItem], taxNumber: NSNumber?, shippingAndHandling: String?, properties: Dictionary<String, String>?) {
        self.init(orderID: orderID, status: status, storeID: storeID, customerID: customerID, shippingAddress: shippingAddress, billingAddress: billingAddress, items: items, tax: taxNumber?.doubleValue, shippingAndHandling: shippingAndHandling, properties: properties)
    }
    
    public init(orderID: String, status: String, storeID: String, customerID: String, shippingAddress: Address, billingAddress: Address, items: [CartItem], tax: Double?, shippingAndHandling: String?, properties: Dictionary<String, String>?) {
        self.orderID = orderID
        self.status = status
        self.storeID = storeID
        self.customerID = customerID
        self.purchaseDate = Date()
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.items = items
        self.tax = tax
        self.shippingAndHandling = shippingAndHandling
        self.properties = properties
    }
    
    @objc public func setPurchaseDate(date: Date) {
        self.purchaseDate = date
    }
    
    @objc public func getPurchaseDate() -> String {
        return CordialDateFormatter().getTimestampFromDate(date: self.purchaseDate)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.orderID, forKey: Key.orderID.rawValue)
        aCoder.encode(self.status, forKey: Key.status.rawValue)
        aCoder.encode(self.storeID, forKey: Key.storeID.rawValue)
        aCoder.encode(self.customerID, forKey: Key.customerID.rawValue)
        aCoder.encode(self.purchaseDate, forKey: Key.purchaseDate.rawValue)
        aCoder.encode(self.shippingAddress, forKey: Key.shippingAddress.rawValue)
        aCoder.encode(self.billingAddress, forKey: Key.billingAddress.rawValue)
        aCoder.encode(self.items, forKey: Key.items.rawValue)
        aCoder.encode(self.tax, forKey: Key.tax.rawValue)
        aCoder.encode(self.shippingAndHandling, forKey: Key.shippingAndHandling.rawValue)
        aCoder.encode(self.properties, forKey: Key.properties.rawValue)
    }
    
    private init(orderID: String, status: String, storeID: String, customerID: String, purchaseDate: Date, shippingAddress: Address, billingAddress: Address, items: [CartItem], tax: Double?, shippingAndHandling: String?, properties: Dictionary<String, String>?) {
        self.orderID = orderID
        self.status = status
        self.storeID = storeID
        self.customerID = customerID
        self.purchaseDate = purchaseDate
        self.shippingAddress = shippingAddress
        self.billingAddress = billingAddress
        self.items = items
        self.tax = tax
        self.shippingAndHandling = shippingAndHandling
        self.properties = properties
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let orderID = aDecoder.decodeObject(forKey: Key.orderID.rawValue) as! String
        let status = aDecoder.decodeObject(forKey: Key.status.rawValue) as! String
        let storeID = aDecoder.decodeObject(forKey: Key.storeID.rawValue) as! String
        let customerID = aDecoder.decodeObject(forKey: Key.customerID.rawValue) as! String
        let purchaseDate = aDecoder.decodeObject(forKey: Key.purchaseDate.rawValue) as! Date
        let shippingAddress = aDecoder.decodeObject(forKey: Key.shippingAddress.rawValue) as! Address
        let billingAddress = aDecoder.decodeObject(forKey: Key.billingAddress.rawValue) as! Address
        let items = aDecoder.decodeObject(forKey: Key.items.rawValue) as! [CartItem]
        let tax = aDecoder.decodeObject(forKey: Key.tax.rawValue) as! Double?
        let shippingAndHandling = aDecoder.decodeObject(forKey: Key.shippingAndHandling.rawValue) as! String?
        let properties = aDecoder.decodeObject(forKey: Key.properties.rawValue) as! Dictionary<String, String>?
        
        self.init(orderID: orderID, status: status, storeID: storeID, customerID: customerID, purchaseDate: purchaseDate, shippingAddress: shippingAddress, billingAddress: billingAddress, items: items, tax: tax, shippingAndHandling: shippingAndHandling, properties: properties)
    }
}
