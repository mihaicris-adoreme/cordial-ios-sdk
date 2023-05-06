//
//  CordialVanityDeepLink.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.01.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

class CordialVanityDeepLink {
    
    let redirectsCountMax = 3
    
    func open(url: URL) {
        NotificationManager.shared.originDeepLink = url.absoluteString
        
        self.getDeepLink(url: url, onSuccess: { url in
            InternalCordialAPI().openDeepLink(url: url)
            
            NotificationManager.shared.vanityDeepLink = String()
            
            LoggerManager.shared.info(message: "Vanity DeepLink converted successfully", category: "CordialSDKDeepLinks")
            
        }, onFailure: { error in
            if !NotificationManager.shared.vanityDeepLink.isEmpty,
               let vanityDeepLinkURL = URL(string: NotificationManager.shared.vanityDeepLink) {
                
                InternalCordialAPI().openDeepLink(url: vanityDeepLinkURL)
            } else {
                InternalCordialAPI().openDeepLink(url: url)
            }
            
            NotificationManager.shared.vanityDeepLink = String()
            
            LoggerManager.shared.error(message: "Vanity DeepLink opening failed. Error: [\(error)]", category: "CordialSDKDeepLinks")
        })
    }
    
    func getDeepLink(url: URL, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        if let host = url.host,
           CordialApiConfiguration.shared.vanityDomains.contains(host) {
            
            self.fetchDeepLink(url: url, redirectsCount: 0, onSuccess: { url in
                onSuccess(url)
            }, onFailure: { error in
                onFailure(error)
            })
        } else {
            onSuccess(url)
        }
    }
    
    private func fetchDeepLink(url: URL, redirectsCount: Int, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        DependencyConfiguration.shared.vanityDeepLinkURLSession.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    onFailure("Fetching Vanity DeepLink failed. Error: [\(error.localizedDescription)]")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        onSuccess(url)
                    case 302:
                        self.parseDeepLink(httpResponse: httpResponse, onSuccess: { url in
                            if let host = url.host,
                               CordialApiConfiguration.shared.vanityDomains.contains(host),
                               redirectsCount < self.redirectsCountMax {
                                
                                self.fetchDeepLink(url: url, redirectsCount: redirectsCount + 1, onSuccess: onSuccess, onFailure: onFailure)
                            } else {
                                onSuccess(url)
                            }
                        }, onFailure: { error in
                            onFailure("Parsing Vanity DeepLink failed. Error: [Unexpected error]")
                        })
                    default:
                        onFailure("Fetching Vanity DeepLink failed. Error: [Unexpected error]")
                    }
                } else {
                    onFailure("Fetching Vanity DeepLink failed. Error: [Unexpected error]")
                }
            }
        }.resume()
    }
    
    private func parseDeepLink(httpResponse: HTTPURLResponse, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        if let location = httpResponse.allHeaderFields["Location"] as? String,
           let url = URL(string: location) {
            
            if let mcID = httpResponse.allHeaderFields["x-mcid"] as? String {
            
                var isTest = false
                if let isTestHeaderString = httpResponse.allHeaderFields["x-message-istest"] as? String,
                   isTestHeaderString.trimmingCharacters(in: .whitespacesAndNewlines) != "0" {
                    
                    isTest = true
                }
                
                if !isTest {
                    CordialAPI().setCurrentMcID(mcID: mcID)
                }
            }
            
            onSuccess(url)
        } else {
            let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
            
            onFailure("Fetching Vanity DeepLink failed. \(message)")
        }
    }
}
