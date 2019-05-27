//
//  CordialContinueRestorationHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 5/24/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class CordialContinueRestorationHandler: CordialContinueRestorationDelegate {
    
    func appOpenViaUniversalLink(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL, let host = url.host,
            let products = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }
        
        if let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            let productViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                productViewController.product = product
                appDelegate.window?.rootViewController = productViewController
            }
            
            return true
        }
        
        if let webpageUrl = URL(string: "https://\(host)/") {
            application.open(webpageUrl)
            return false
        }
        
        return false
    }

}
