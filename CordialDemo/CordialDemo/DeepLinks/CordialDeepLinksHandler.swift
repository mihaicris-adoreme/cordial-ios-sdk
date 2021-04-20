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
    
    let deepLinksHost = "tjs.cordialdev.com"
    
    func openDeepLink(url: URL, fallbackURL: URL?) {
        guard let host = self.getHost(url: url, fallbackURL: fallbackURL) else {
            return
        }
        
        DispatchQueue.main.async {
            if host == self.deepLinksHost {
                if let deepLinkURL = self.getDeepLinkURL(url: url),
                   let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
                   let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                    
                    self.showAppDelegateDeepLink(product: product)
                    
                } else if let fallbackURL = self.getDeepLinkURL(url: fallbackURL),
                          let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true),
                          let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                    
                    self.showAppDelegateDeepLink(product: product)
                    
                } else if let webpageUrl = URL(string: "https://\(host)/") {
                    
                    UIApplication.shared.open(webpageUrl)
                }
            } else {
                UIApplication.shared.open(url)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene) {
        guard let host = self.getHost(url: url, fallbackURL: fallbackURL) else {
            return
        }
        
        DispatchQueue.main.async {
            if host == self.deepLinksHost {
                if let deepLinkURL = self.getDeepLinkURL(url: url),
                   let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
                   let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                    
                    self.showSceneDelegateDeepLink(product: product, scene: scene)
                    
                } else if let fallbackURL = self.getDeepLinkURL(url: fallbackURL),
                          let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true),
                          let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                    
                    self.showSceneDelegateDeepLink(product: product, scene: scene)
                    
                } else if let webpageUrl = URL(string: "https://\(host)/") {
                    
                    UIApplication.shared.open(webpageUrl)
                }
            } else {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func getHost(url: URL, fallbackURL: URL?) -> String? {
        if let urlString = url.absoluteString.removingPercentEncoding,
           let urlDecode = URL(string: urlString),
           urlDecode.host != nil {
            
            return urlDecode.host
        }
        
        if let fallbackURLString = fallbackURL?.absoluteString.removingPercentEncoding,
           let fallbackURLDecode = URL(string: fallbackURLString),
           fallbackURLDecode.host != nil {
            
            return fallbackURLDecode.host
        }
        
        return nil
    }
    
    private func getDeepLinkURL(url: URL?) -> URL? {
        guard let dencodedURLString = url?.absoluteString.removingPercentEncoding else {
            return nil
        }
        
        let dencodedURLArray = dencodedURLString.split(separator: "?")
        let deepLink = String(dencodedURLArray[0])
        
        guard let deepLinkURL = URL(string: deepLink) else {
            return nil
        }
        
        return deepLinkURL
    }
    
    private func showAppDelegateDeepLink(product: Product) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let productViewController = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.product = product
        
        let catalogNavigationController = storyboard.instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
        catalogNavigationController.pushViewController(productViewController, animated: false)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = catalogNavigationController
        }
    }
    
    @available(iOS 13.0, *)
    private func showSceneDelegateDeepLink(product: Product, scene: UIScene) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let productViewController = storyboard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.product = product
        
        let catalogNavigationController = storyboard.instantiateViewController(withIdentifier: "CatalogNavigationController") as! UINavigationController
        catalogNavigationController.pushViewController(productViewController, animated: false)
        
        if let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = catalogNavigationController
        }
    }
}
