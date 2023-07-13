//
//  Product.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class Product: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding = true
    
    let id: String
    let img: String
    let brand: String
    let name: String
    let price: Int
    let sku: String
    let shortDescription: String
    let image: String
    let path: String
        
    init(id: String, img: String, brand: String, name: String, price: Int, sku: String, shortDescription: String, image: String, path: String) {
        self.id = id
        self.img = img
        self.brand = brand
        self.name = name
        self.price = price
        self.sku = sku
        self.shortDescription = shortDescription
        self.image = image
        self.path = path
    }
    
    enum Key: String {
        case id = "id"
        case img = "img"
        case brand = "brand"
        case name = "name"
        case price = "price"
        case sku = "sku"
        case shortDescription = "shortDescription"
        case image = "image"
        case path = "path"
    }

    
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: Key.id.rawValue)
        coder.encode(self.img, forKey: Key.img.rawValue)
        coder.encode(self.brand, forKey: Key.brand.rawValue)
        coder.encode(self.name, forKey: Key.name.rawValue)
        coder.encode(self.price, forKey: Key.price.rawValue)
        coder.encode(self.sku, forKey: Key.sku.rawValue)
        coder.encode(self.shortDescription, forKey: Key.shortDescription.rawValue)
        coder.encode(self.image, forKey: Key.image.rawValue)
        coder.encode(self.path, forKey: Key.path.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        let id = coder.decodeObject(forKey: Key.id.rawValue) as! String
        let img = coder.decodeObject(forKey: Key.img.rawValue) as! String
        let brand = coder.decodeObject(forKey: Key.brand.rawValue) as! String
        let name = coder.decodeObject(forKey: Key.name.rawValue) as! String
        let price = coder.decodeInteger(forKey: Key.price.rawValue)
        let sku = coder.decodeObject(forKey: Key.sku.rawValue) as! String
        let shortDescription = coder.decodeObject(forKey: Key.shortDescription.rawValue) as! String
        let image = coder.decodeObject(forKey: Key.image.rawValue) as! String
        let path = coder.decodeObject(forKey: Key.path.rawValue) as! String
        
        self.init(id: id, img: img, brand: brand, name: name, price: price, sku: sku, shortDescription: shortDescription, image: image, path: path)
    }
}
