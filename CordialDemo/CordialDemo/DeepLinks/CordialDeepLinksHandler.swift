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
    
    func openDeepLink(url: URL, fallbackURL: URL?) {
        // If app dose not use scenes this method will be called instead `openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene)`
        
        guard let host = url.host else {
            return
        }
        
        if let products = URLComponents(url: url, resolvingAgainstBaseURL: true), let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            self.showDeepLink(product: product, scene: nil)
        } else if let fallbackURL = fallbackURL, let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true), let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            self.showDeepLink(product: product, scene: nil)
        } else if let webpageUrl = URL(string: "https://\(host)/") {
            UIApplication.shared.open(webpageUrl)
        }
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene) {
        guard let host = url.host else {
            return
        }
        
        if let products = URLComponents(url: url, resolvingAgainstBaseURL: true), let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            self.showDeepLink(product: product, scene: scene)
        } else if let fallbackURL = fallbackURL, let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true), let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
            self.showDeepLink(product: product, scene: scene)
        } else if let webpageUrl = URL(string: "https://\(host)/") {
            UIApplication.shared.open(webpageUrl)
        }
    }
    
    private func showDeepLink(product: Product, scene: UIScene?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let productViewController = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.product = product
        
        let catalogNavigationController = storyboard.instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
        catalogNavigationController.pushViewController(productViewController, animated: false)
        
        if let scene = scene, let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = catalogNavigationController
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = catalogNavigationController
        }
    }
}
