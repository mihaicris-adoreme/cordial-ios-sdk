//
//  CordialEmailDeepLink.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.01.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialEmailDeepLink {
    
    func open(url: URL) {
        self.fetchDeepLink(url: url, onSuccess: { url in
            InternalCordialAPI().openDeepLink(url: url)
            
            NotificationManager.shared.emailDeepLink = String()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Email DeepLink converted successfully", log: OSLog.cordialDeepLinks, type: .info)
            }
        }, onFailure: { error in
            if let emailDeepLinkURL = URL(string: NotificationManager.shared.emailDeepLink),
               let cordialDeepLinksDelegate = CordialApiConfiguration.shared.cordialDeepLinksDelegate {
                
                if #available(iOS 13.0, *), let scene = UIApplication.shared.connectedScenes.first {
                    cordialDeepLinksDelegate.openDeepLink(url: emailDeepLinkURL, fallbackURL: nil, scene: scene)
                } else {
                    cordialDeepLinksDelegate.openDeepLink(url: emailDeepLinkURL, fallbackURL: nil)
                }
            }
            
            NotificationManager.shared.emailDeepLink = String()
            
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Email DeepLink opening failed. Error: [%{public}@]", log: OSLog.cordialDeepLinks, type: .error, error)
            }
        })
    }
    
    private func fetchDeepLink(url: URL, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        DependencyConfiguration.shared.emailDeepLinkURLSession.dataTask(with: url) { data, response, error in
            if let error = error {
                onFailure("Fetching Email DeepLink failed. Error: [\(error.localizedDescription)]")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 302,
                   let location = httpResponse.allHeaderFields["Location"] as? String,
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
                    
                    onFailure("Fetching Email DeepLink failed. \(message)")
                }
            } else {
                onFailure("Fetching Email DeepLink failed. Error: [Unexpected error]")
            }
        }.resume()
    }
    
}
