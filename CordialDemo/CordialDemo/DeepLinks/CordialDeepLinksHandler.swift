//
//  CordialDeepLinksHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 09.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class CordialDeepLinksHandler: CordialDeepLinksDelegate {
    
    func openDeepLink(url: URL) {
        guard let host = url.host, let products = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        if let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let productViewController = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
                productViewController.product = product
                
                let catalogNavigationController = storyboard.instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
                catalogNavigationController.pushViewController(productViewController, animated: false)
                
                appDelegate.window?.rootViewController = catalogNavigationController
            }
            
            return
        }
        
        if let webpageUrl = URL(string: "https://\(host)/") {
            UIApplication.shared.open(webpageUrl)
            return
        }
        
        return
    }
    
}
