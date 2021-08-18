//
//  DeepLinks.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 10.06.2021.
//

import Foundation
import UIKit

struct DeepLinks {
    
    let deepLinksHost = "tjs.cordialdev.com"
    
    func getProductID(url: URL) -> Int? {
        if url.absoluteString.contains("notification-settings") {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            return nil
        }
        
        guard let host = self.getHost(url: url) else {
            return nil
        }
        
        if host == self.deepLinksHost {
            if let deepLinkURL = self.getDeepLinkURL(url: url),
               let products = URLComponents(url: deepLinkURL, resolvingAgainstBaseURL: true),
               let product = ProductHandler.shared.products.filter({ $0.path == products.path }).first {
                
                return product.id
                
            } else if let webpageURL = URL(string: "https://\(host)/") {
                
                self.openWebpageURL(url: webpageURL)
            }
        } else {
            self.openWebpageURL(url: url)
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
