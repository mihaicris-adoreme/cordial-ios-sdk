//
//  CordialDeepLinksInternal.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 04.01.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

class CordialDeepLinksInternal {
    
    private let products = [
        CordialDeepLinksInternalData(id: "1",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/crew-neck-cotton-undershirt")!),
        CordialDeepLinksInternalData(id: "2",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/the-basic-shirt")!),
        CordialDeepLinksInternalData(id: "3",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/crew-neck-t")!),
        CordialDeepLinksInternalData(id: "4",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/relaxed-shirt")!),
        CordialDeepLinksInternalData(id: "5",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/classic-denim-long-sleeve")!),
        CordialDeepLinksInternalData(id: "6",
                                     url: URL(string: "https://store.cordialthreads.com/collections/mens/products/wide-neck-long-sleeve")!)
    ]
    
    func getProductDeepLinkInternal(url: URL) -> Product? {
        let productsFiltered = self.products.filter { product in
            if url.absoluteString.contains(product.url.absoluteString) {
                return true
            }
            
            return false
        }

        if let productFiltered = productsFiltered.first,
           let product = ProductHandler.shared.products.filter({ $0.id == productFiltered.id }).first {
            
            return product
        }
        
        return nil
    }
}
