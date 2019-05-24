//
//  Product.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class Product: NSObject, NSCoding {
    
    let id: String
    let img: String
    let brand: String
    let name: String
    let price: Double
    let sku: String
    let shortDescription: String
    let path: String
    
    enum Key: String {
        case id = "id"
        case img = "img"
        case brand = "brand"
        case name = "name"
        case price = "price"
        case sku = "sku"
        case shortDescription = "shortDescription"
        case path = "path"
    }
    
    init(id: String, img: String, brand: String, name: String, price: Double, sku: String, shortDescription: String, path: String) {
        self.id = id
        self.img = img
        self.brand = brand
        self.name = name
        self.price = price
        self.sku = sku
        self.shortDescription = shortDescription
        self.path = path
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: Key.id.rawValue)
        aCoder.encode(self.img, forKey: Key.img.rawValue)
        aCoder.encode(self.brand, forKey: Key.brand.rawValue)
        aCoder.encode(self.name, forKey: Key.name.rawValue)
        aCoder.encode(self.price, forKey: Key.price.rawValue)
        aCoder.encode(self.sku, forKey: Key.sku.rawValue)
        aCoder.encode(self.shortDescription, forKey: Key.shortDescription.rawValue)
        aCoder.encode(self.path, forKey: Key.path.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: Key.id.rawValue) as! String
        let img = aDecoder.decodeObject(forKey: Key.img.rawValue) as! String
        let brand = aDecoder.decodeObject(forKey: Key.brand.rawValue) as! String
        let name = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
        let price = aDecoder.decodeDouble(forKey: Key.price.rawValue)
        let sku = aDecoder.decodeObject(forKey: Key.sku.rawValue) as! String
        let shortDescription = aDecoder.decodeObject(forKey: Key.shortDescription.rawValue) as! String
        let path = aDecoder.decodeObject(forKey: Key.path.rawValue) as! String
        
        self.init(id: id, img: img, brand: brand, name: name, price: price, sku: sku, shortDescription: shortDescription, path: path)
    }
}
