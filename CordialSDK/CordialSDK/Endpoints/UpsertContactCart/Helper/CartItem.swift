//
//  CartItem.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class CartItem: NSObject, NSCoding {

    let productID: String
    let name: String
    let sku: String
    let category: String?
    let url: String?
    let itemDescription: String?
    let qty: Int64?
    let itemPrice: Double?
    let salePrice: Double?
    let timestamp: String
    let attr: Dictionary<String, String>?
    let images: [String]?
    let properties: Dictionary<String, String>?
        
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
    
    @objc public convenience init(productID: String, name: String, sku: String, category: String?, url: String?, itemDescription: String?, qtyNumber: NSNumber?, itemPriceNumber: NSNumber?, salePriceNumber: NSNumber?, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, String>?) {
        self.init(productID: productID, name: name, sku: sku, category: category, url: url, itemDescription: itemDescription, qty: qtyNumber?.int64Value, itemPrice: itemPriceNumber?.doubleValue, salePrice: salePriceNumber?.doubleValue, attr: attr, images: images, properties: properties)
    }
    
    public init(productID: String, name: String, sku: String, category: String?, url: String?, itemDescription: String?, qty: Int64?, itemPrice: Double?, salePrice: Double?, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, String>?) {
        self.productID = productID
        self.name = name
        self.sku = sku
        self.category = category
        self.url = url
        self.itemDescription = itemDescription
        self.qty = qty
        self.itemPrice = itemPrice
        self.salePrice = salePrice
        self.timestamp = DateFormatter().getCurrentTimestamp()
        self.attr = attr
        self.images = images
        self.properties = properties
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.productID, forKey: Key.productID.rawValue)
        aCoder.encode(self.name, forKey: Key.name.rawValue)
        aCoder.encode(self.sku, forKey: Key.sku.rawValue)
        aCoder.encode(self.category, forKey: Key.category.rawValue)
        aCoder.encode(self.url, forKey: Key.url.rawValue)
        aCoder.encode(self.itemDescription, forKey: Key.itemDescription.rawValue)
        aCoder.encode(self.qty, forKey: Key.qty.rawValue)
        aCoder.encode(self.itemPrice, forKey: Key.itemPrice.rawValue)
        aCoder.encode(self.salePrice, forKey: Key.salePrice.rawValue)
        aCoder.encode(self.timestamp, forKey: Key.timestamp.rawValue)
        aCoder.encode(self.attr, forKey: Key.attr.rawValue)
        aCoder.encode(self.images, forKey: Key.images.rawValue)
        aCoder.encode(self.properties, forKey: Key.properties.rawValue)
    }
    
    private init(productID: String, name: String, sku: String, category: String?, url: String?, itemDescription: String?, qty: Int64?, itemPrice: Double?, salePrice: Double?, timestamp: String, attr: Dictionary<String, String>?, images: [String]?, properties: Dictionary<String, String>?) {
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
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        let productID = aDecoder.decodeObject(forKey: Key.productID.rawValue) as! String
        let name = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let sku = aDecoder.decodeObject(forKey: Key.sku.rawValue) as! String
        let category = aDecoder.decodeObject(forKey: Key.category.rawValue) as! String?
        let url = aDecoder.decodeObject(forKey: Key.url.rawValue) as! String?
        let itemDescription = aDecoder.decodeObject(forKey: Key.itemDescription.rawValue) as! String?
        let qty = aDecoder.decodeObject(forKey: Key.qty.rawValue) as! Int64?
        let itemPrice = aDecoder.decodeObject(forKey: Key.itemPrice.rawValue) as! Double?
        let salePrice = aDecoder.decodeObject(forKey: Key.salePrice.rawValue) as! Double?
        let timestamp = aDecoder.decodeObject(forKey: Key.timestamp.rawValue) as! String
        let attr = aDecoder.decodeObject(forKey: Key.attr.rawValue) as! Dictionary<String, String>?
        let images = aDecoder.decodeObject(forKey: Key.images.rawValue) as! [String]?
        let properties = aDecoder.decodeObject(forKey: Key.properties.rawValue) as! Dictionary<String, String>?
        
        self.init(productID: productID, name: name, sku: sku, category: category, url: url, itemDescription: itemDescription, qty: qty, itemPrice: itemPrice, salePrice: salePrice, timestamp: timestamp, attr: attr, images: images, properties: properties)
    }
}
