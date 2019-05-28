//
//  CordialOpenOptionsHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class CordialOpenOptionsHandler: CordialOpenOptionsDelegate {
    
    func appOpenViaUrlScheme(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {

        let urlScheme = "cordial"
        
        guard let scheme = url.scheme, scheme.localizedCaseInsensitiveCompare(urlScheme) == .orderedSame, let host = url.host,
            let products = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
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
            
            return true
        }
        
        if let webpageUrl = URL(string: "https://\(host)/") {
            app.open(webpageUrl)
            return false
        }
        
        return false
    }
    
}
