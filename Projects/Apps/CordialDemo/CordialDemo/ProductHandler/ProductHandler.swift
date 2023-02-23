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
                brand: "Brooklyn Clothing Co.",
                name: "The Cotton Crew",
                price: 30,
                sku: "ab26ec3a-6110-11e9-8647-d663bd873d93",
                shortDescription: "Classic T-shirt that is designed to be one of the most comfortable tees you'll ever own. Featuring the brushed cotton fabric for exceptional comfort, and the body length that is well proportioned to complement your body - whether on its own or when layering with other pieces.",
                image: "https://i.imgur.com/XlboRqm.png",
                path: "/prep-tj1.html"),
        Product(id: "2",
                img: "men2",
                brand: "Brooklyn Clothing Co.",
                name: "The Basic Shirt",
                price: 45,
                sku: "ab26efdc-6110-11e9-8647-d663bd873d93",
                shortDescription: "Get yourself into a crisp new white T for the summer. This go-to street wear never goes out of style, and it can go anywhere you want it to in the hot streets of NYC. 100% cotton to catch those cool breezes, and 100% cool to catch those breezy babes.",
                image: "https://i.imgur.com/vsv5Ay9.png",
                path: "/prep-tj2.html"),
        Product(id: "3",
                img: "men3",
                brand: "Hugo Boss",
                name: "Modern Crewneck T-Shirt",
                price: 50,
                sku: "ab26f446-6110-11e9-8647-d663bd873d93",
                shortDescription: "Stay stylish and comfortable all day long with our Modern Crewneck T-Shirt - featuring a lightweight cotton blend fabric that also retains a flattering shape.",
                image: "https://i.imgur.com/9k4hG7k.png",
                path: ""),
        Product(id: "4",
                img: "men4",
                brand: "Cariuma",
                name: "Relaxed Shirt",
                price: 55,
                sku: "ab26f5b8-6110-11e9-8647-d663bd873d93",
                shortDescription: "This 100% cotton long sleeve will drape and flow and furl around you as you vibe your way through life. Chill out, relax and max out all your cool, play a little B-ball outside of the school... \n\nThat's Cariuma fresh.",
                image: "https://i.imgur.com/I3v2qVB.png",
                path: ""),
        Product(id: "5",
                img: "men5",
                brand: "John Elliot",
                name: "Classic Denim Shirt",
                price: 55,
                sku: "ab26f75c-6110-11e9-8647-d663bd873d93",
                shortDescription: "Nothing adds touch of Western authenticity to your outfit like our Classic Denim Shirt. Perfect for the office, date night, or when you're feeling like pulling a Canadian Tuxedo outfit.",
                image: "https://i.imgur.com/EDr9Iwp.png",
                path: ""),
        Product(id: "6",
                img: "men6",
                brand: "John Elliot",
                name: "Wide-Neck Longsleeve",
                price: 55,
                sku: "ab26f89c-6110-11e9-8647-d663bd873d93",
                shortDescription: "Stay cozy this Fall and Winter season with our Wide-Neck Longsleeve. Featuring the classic crewneck with strong ladder stitch for a slim yet relaxed fit.",
                image: "https://i.imgur.com/z569cAr.png",
                path: "")
    ]
    
}
