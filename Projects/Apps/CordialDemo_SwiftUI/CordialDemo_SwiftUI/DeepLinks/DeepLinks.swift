//
//  DeepLinks.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import Foundation
import UIKit
import CordialSDK

struct DeepLinks {
    
    var deepLinks: CordialSwiftUIDeepLinks
    
    let deepLinksHost = "tjs.cordialdev.com"
    
    func getProductID() -> Int? {        
        if deepLinks.url.absoluteString.contains("notification-settings") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            return nil
        }
        
        guard let host = self.getHost(url: deepLinks.url) else { return nil }
        
        if host == self.deepLinksHost {
            if let deepLinkURL = self.getDeepLinkURL(url: deepLinks.url),
               let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
               let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                
                return product.id
                
            } else if let fallbackURL = self.getDeepLinkURL(url: deepLinks.fallbackURL),
                      let products = URLComponents(url: fallbackURL, resolvingAgainstBaseURL: true),
                      let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                
                return product.id
                
            } else {
                deepLinks.completionHandler(.OPEN_IN_BROWSER)
            }
        } else {
            self.openWebpageURL(url: deepLinks.url)
        }
        
        return nil
    }
    
    private func openWebpageURL(url: URL) {
        if let urlString = url.absoluteString.removingPercentEncoding,
           let urlDecode = URL(string: urlString) {
            
            UIApplication.shared.open(urlDecode)
        }
    }
    
    private func getHost(url: URL) -> String? {
        if let urlString = url.absoluteString.removingPercentEncoding,
           let urlDecode = URL(string: urlString),
           urlDecode.host != nil {
            
            return urlDecode.host
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

} 
