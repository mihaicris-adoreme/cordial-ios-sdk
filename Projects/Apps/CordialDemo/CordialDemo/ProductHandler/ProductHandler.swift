//
//  ProductHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/24/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class ProductHandler {
    static let shared = ProductHandler()
    
    private init() {}
    
    let products = [
        Product(id: "1",
                img: "men1",
                brand: "Robert Graham",
                name: "Alix Long Sleeve Woven Shirt",
                price: 148.00,
                sku: "ab26ec3a-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/h034GAS.jpeg",
                path: "/prep-tj1.html"),
        Product(id: "2",
                img: "men2",
                brand: "Robert Graham",
                name: "Back Off Polo",
                price: 98.00,
                sku: "ab26efdc-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/wPW6Yv5.jpeg",
                path: "/prep-tj2.html"),
        Product(id: "3",
                img: "men3",
                brand: "Robert Graham",
                name: "Back Off Polo",
                price: 98.00,
                sku: "ab26f446-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/kZ5wXr7.jpeg",
                path: ""),
        Product(id: "4",
                img: "men4",
                brand: "Robert Graham",
                name: "Baylor Long Sleeve Woven Shirt",
                price: 148.00,
                sku: "ab26f5b8-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/z5WFRWh.jpeg",
                path: ""),
        Product(id: "5",
                img: "men5",
                brand: "DSQUARED2",
                name: "Black Watch Woven Shirt",
                price: 685.00,
                sku: "ab26f75c-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/dVCoPeS.jpeg",
                path: ""),
        Product(id: "6",
                img: "men6",
                brand: "Rip Curl",
                name: "Botanical Short Sleeve Shirt",
                price: 54.50,
                sku: "ab26f89c-6110-11e9-8647-d663bd873d93",
                shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size",
                image: "https://i.imgur.com/Uz9RrEq.jpeg",
                path: "")
    ]
    
}
