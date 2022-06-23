//
//  CordialDeepLinksHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 09.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK
import os.log

class CordialDeepLinksHandler: CordialDeepLinksDelegate {
    
    let deepLinksHost = "tjs.cordialdev.com"
    
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        let url = deepLink.url
        
        CordialDeepLinksHelper().baseLogsOutput(url: url, vanityURL: deepLink.vanityURL, fallbackURL: fallbackURL)
        
        DispatchQueue.main.async {
            if url.absoluteString.contains("notification-settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                return
            }

            guard let host = self.getHost(url: url, fallbackURL: fallbackURL) else {
                return
            }

            if host == self.deepLinksHost {
                if let deepLinkURL = self.getDeepLinkURL(url: url),
                   let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
                   let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {

                    self.showAppDelegateDeepLink(product: product)

                } else if let fallbackURL = self.getDeepLinkURL(url: fallbackURL),
                          let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true),
                          let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {

                    self.showAppDelegateDeepLink(product: product)

                } else {
                    completionHandler(.OPEN_IN_BROWSER)
                }
            } else {
                self.openWebpageURL(url: url)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, scene: UIScene, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        let url = deepLink.url
        
        CordialDeepLinksHelper().baseLogsOutput(url: url, vanityURL: deepLink.vanityURL, fallbackURL: fallbackURL)
        
        DispatchQueue.main.async {
            if url.absoluteString.contains("notification-settings") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                return
            }

            guard let host = self.getHost(url: url, fallbackURL: fallbackURL) else {
                return
            }

            if host == self.deepLinksHost {
                if let deepLinkURL = self.getDeepLinkURL(url: url),
                   let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
                   let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {

                    self.showSceneDelegateDeepLink(product: product, scene: scene)

                } else if let fallbackURL = self.getDeepLinkURL(url: fallbackURL),
                          let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true),
                          let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {

                    self.showSceneDelegateDeepLink(product: product, scene: scene)

                } else {
                    completionHandler(.OPEN_IN_BROWSER)
                }
            } else {
                self.openWebpageURL(url: url)
            }
        }
    }
    
    private func openWebpageURL(url: URL) {
        if let urlString = url.absoluteString.removingPercentEncoding,
           let urlDecode = URL(string: urlString) {
            
            UIApplication.shared.open(urlDecode)
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
