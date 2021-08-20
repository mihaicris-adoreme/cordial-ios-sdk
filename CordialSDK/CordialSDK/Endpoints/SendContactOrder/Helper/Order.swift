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
    let shippingAndHandling: Double?
    let properties: Dictionary<String, Any>?
    
    var isError = false
    
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
    
    @objc public convenience init(orderID: String, status: String, storeID: String, customerID: String, shippingAddress: Address, billingAddress: Address, items: [CartItem], taxNumber: NSNumber?, shippingAndHandling: NSNumber?, properties: Dictionary<String, Any>?) {
        self.init(orderID: orderID, status: status, storeID: storeID, customerID: customerID, shippingAddress: shippingAddress, billingAddress: billingAddress, items: items, tax: taxNumber?.doubleValue, shippingAndHandling: shippingAndHandling?.doubleValue, properties: properties)
    }
    
    public init(orderID: String, status: String, storeID: String, customerID: String, shippingAddress: Address, billingAddress: Address, items: [CartItem], tax: Double?, shippingAndHandling: Double?, properties: Dictionary<String, Any>?) {
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
    
    private init(orderID: String, status: String, storeID: String, customerID: String, purchaseDate: Date, shippingAddress: Address, billingAddress: Address, items: [CartItem], tax: Double?, shippingAndHandling: Double?, properties: Dictionary<String, Any>?) {
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
        if let orderID = aDecoder.decodeObject(forKey: Key.orderID.rawValue) as? String,
           let status = aDecoder.decodeObject(forKey: Key.status.rawValue) as? String,
           let storeID = aDecoder.decodeObject(forKey: Key.storeID.rawValue) as? String,
           let customerID = aDecoder.decodeObject(forKey: Key.customerID.rawValue) as? String,
           let purchaseDate = aDecoder.decodeObject(forKey: Key.purchaseDate.rawValue) as? Date,
           let shippingAddress = aDecoder.decodeObject(forKey: Key.shippingAddress.rawValue) as? Address,
           let billingAddress = aDecoder.decodeObject(forKey: Key.billingAddress.rawValue) as? Address,
           let items = aDecoder.decodeObject(forKey: Key.items.rawValue) as? [CartItem],
           let tax = aDecoder.decodeObject(forKey: Key.tax.rawValue) as? Double?,
           let shippingAndHandling = aDecoder.decodeObject(forKey: Key.shippingAndHandling.rawValue) as? Double?,
           let properties = aDecoder.decodeObject(forKey: Key.properties.rawValue) as? Dictionary<String, Any>? {
            
            var isItemError = false
            items.forEach { item in
                if item.isError {
                    isItemError = true
                }
            }
            
            if !isItemError, !shippingAddress.isError, !billingAddress.isError {

                self.init(orderID: orderID, status: status, storeID: storeID, customerID: customerID, purchaseDate: purchaseDate, shippingAddress: shippingAddress, billingAddress: billingAddress, items: items, tax: tax, shippingAndHandling: shippingAndHandling, properties: properties)
            } else {
                let address = Address(name: String(), address: String(), city: String(), state: String(), postalCode: String(), country: String())
                let cartItem = CartItem(productID: String(), name: String(), sku: String(), category: String(), url: nil, itemDescription: nil, qty: 1, itemPrice: nil, salePrice: nil, attr: nil, images: nil, properties: nil)
                self.init(orderID: String(), status: String(), storeID: String(), customerID: String(), shippingAddress: address, billingAddress: address, items: [cartItem], tax: nil, shippingAndHandling: nil, properties: nil)
                
                self.isError = true
            }
        } else {
            let address = Address(name: String(), address: String(), city: String(), state: String(), postalCode: String(), country: String())
            let cartItem = CartItem(productID: String(), name: String(), sku: String(), category: String(), url: nil, itemDescription: nil, qty: 1, itemPrice: nil, salePrice: nil, attr: nil, images: nil, properties: nil)
            self.init(orderID: String(), status: String(), storeID: String(), customerID: String(), shippingAddress: address, billingAddress: address, items: [cartItem], tax: nil, shippingAndHandling: nil, properties: nil)
            
            self.isError = true
        }
    }
}
