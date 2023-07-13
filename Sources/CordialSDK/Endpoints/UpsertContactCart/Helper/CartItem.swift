//
//  CartItem.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class CartItem: NSObject, NSCoding, NSSecureCoding {

    public static var supportsSecureCoding = true
    
    let productID: String
    let name: String
    let sku: String
    let category: String
    let url: String?
    let itemDescription: String?
    let qty: Int64
    let itemPrice: Double?
    let salePrice: Double?
    var timestamp: String
    let attr: Dictionary<String, String>?
    let images: [String]?
    let properties: Dictionary<String, Any>?
    
    var isError = false
        
    enum Key: String {
        case productID = "productID"
        case name = "name"
        case sku = "sku"
        case category = "category"
        case url = "url"
        case itemDescription = "itemDescription"
        case qty = "qty"
        case itemPrice = "itemPrice"
        case salePrice = "salePrice"
        case timestamp = "timestamp"
        case attr = "attr"
        case images = "images"
        case properties = "properties"
    }
    
    public convenience init(productID: String, name: String, sku: String, category: String, url: String?, itemDescription: String?, qtyNumber: NSNumber, itemPriceNumber: NSNumber?, salePriceNumber: NSNumber?, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, Any>?) {
        self.init(productID: productID, name: name, sku: sku, category: category, url: url, itemDescription: itemDescription, qty: qtyNumber.int64Value, itemPrice: itemPriceNumber?.doubleValue, salePrice: salePriceNumber?.doubleValue, attr: attr, images: images, properties: properties)
    }
    
    public init(productID: String, name: String, sku: String, category: String, url: String?, itemDescription: String?, qty: Int64, itemPrice: Double?, salePrice: Double?, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, Any>?) {
        self.productID = productID
        self.name = name
        self.sku = sku
        self.category = category
        self.url = url
        self.itemDescription = itemDescription
        self.qty = qty
        self.itemPrice = itemPrice
        self.salePrice = salePrice
        self.timestamp = CordialDateFormatter().getCurrentTimestamp()
        self.attr = attr
        self.images = images
        self.properties = properties
    }
    
    public func seTimestamp(date: Date) {
        let timestamp = CordialDateFormatter().getTimestampFromDate(date: date)
        
        self.timestamp = timestamp
    }
    
    public func getTimestamp() -> String {
        return self.timestamp
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.productID, forKey: Key.productID.rawValue)
        coder.encode(self.name, forKey: Key.name.rawValue)
        coder.encode(self.sku, forKey: Key.sku.rawValue)
        coder.encode(self.category, forKey: Key.category.rawValue)
        coder.encode(self.url, forKey: Key.url.rawValue)
        coder.encode(self.itemDescription, forKey: Key.itemDescription.rawValue)
        coder.encode(self.qty, forKey: Key.qty.rawValue)
        coder.encode(self.itemPrice, forKey: Key.itemPrice.rawValue)
        coder.encode(self.salePrice, forKey: Key.salePrice.rawValue)
        coder.encode(self.timestamp, forKey: Key.timestamp.rawValue)
        coder.encode(self.attr, forKey: Key.attr.rawValue)
        coder.encode(self.images, forKey: Key.images.rawValue)
        coder.encode(self.properties, forKey: Key.properties.rawValue)
    }
    
    private init(productID: String, name: String, sku: String, category: String, url: String?, itemDescription: String?, qty: Int64, itemPrice: Double?, salePrice: Double?, timestamp: String, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, Any>?) {
        self.productID = productID
        self.name = name
        self.sku = sku
        self.category = category
        self.url = url
        self.itemDescription = itemDescription
        self.qty = qty
        self.itemPrice = itemPrice
        self.salePrice = salePrice
        self.timestamp = timestamp
        self.attr = attr
        self.images = images
        self.properties = properties
    }
    
    public required convenience init?(coder: NSCoder) {
        if let productID = coder.decodeObject(forKey: Key.productID.rawValue) as? String,
           let name = coder.decodeObject(forKey: Key.name.rawValue) as? String,
           let sku = coder.decodeObject(forKey: Key.sku.rawValue) as? String,
           let category = coder.decodeObject(forKey: Key.category.rawValue) as? String,
           let url = coder.decodeObject(forKey: Key.url.rawValue) as? String?,
           let itemDescription = coder.decodeObject(forKey: Key.itemDescription.rawValue) as? String?,
           let itemPrice = coder.decodeObject(forKey: Key.itemPrice.rawValue) as? Double?,
           let salePrice = coder.decodeObject(forKey: Key.salePrice.rawValue) as? Double?,
           let timestamp = coder.decodeObject(forKey: Key.timestamp.rawValue) as? String,
           let attr = coder.decodeObject(forKey: Key.attr.rawValue) as? Dictionary<String, String>?,
           let images = coder.decodeObject(forKey: Key.images.rawValue) as? [String]?,
           let properties = coder.decodeObject(forKey: Key.properties.rawValue) as? Dictionary<String, Any>? {
            
            let qty = coder.decodeInt64(forKey: Key.qty.rawValue)
            
            self.init(productID: productID, name: name, sku: sku, category: category, url: url, itemDescription: itemDescription, qty: qty, itemPrice: itemPrice, salePrice: salePrice, timestamp: timestamp, attr: attr, images: images, properties: properties)
        } else {
            self.init(productID: String(), name: String(), sku: String(), category: String(), url: nil, itemDescription: nil, qty: 1, itemPrice: nil, salePrice: nil, attr: nil, images: nil, properties: nil)
            
            self.isError = true
        }
    }
}
