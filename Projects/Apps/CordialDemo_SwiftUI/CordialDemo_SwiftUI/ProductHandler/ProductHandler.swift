//
//  ProductHandler.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import Foundation

class ProductHandler {
    static let shared = ProductHandler()
    
    private init(){}
    
    let products = [
        Product(id: 1, img: "men1", brand: "Robert Graham", name: "Alix Long Sleeve Woven Shirt", price: 148.00, sku: "ab26ec3a-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size", path: "/prep-tj1.html"),
        Product(id: 2, img: "men2", brand: "Robert Graham", name: "Back Off Polo", price: 98.00, sku: "ab26efdc-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size", path: "/prep-tj2.html"),
        Product(id: 3, img: "men3", brand: "Robert Graham", name: "Back Off Polo", price: 98.00, sku: "ab26f446-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size", path: ""),
        Product(id: 4, img: "men4", brand: "Robert Graham", name: "Baylor Long Sleeve Woven Shirt", price: 148.00, sku: "ab26f5b8-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size", path: "")
    ]
    
}

