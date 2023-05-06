//
//  CordialSwiftUIDeepLinksHandler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 18.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

public class CordialSwiftUIDeepLinksHandler {
    
    public init() {}
    
    @available(iOS 13.0, *)
    public func processDeepLink(url: URL) {
        DispatchQueue.main.async {
            NotificationManager.shared.originDeepLink = url.absoluteString
            
            let internalCordialAPI = InternalCordialAPI()
            
            internalCordialAPI.sentEventDeepLinkOpen(url: url)
            
            CordialVanityDeepLink().getDeepLink(url: url, onSuccess: { url in
                let cordialDeepLink = internalCordialAPI.getCordialDeepLink(url: url)
                
                CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(deepLink: cordialDeepLink, fallbackURL: nil, completionHandler: { deepLinkActionType in

                    internalCordialAPI.deepLinkAction(deepLinkActionType: deepLinkActionType)
                })
                
                NotificationManager.shared.vanityDeepLink = String()
                
                LoggerManager.shared.info(message: "Vanity DeepLink converted successfully", category: "CordialSDKDeepLinks")
                
            }, onFailure: { error in
                if !NotificationManager.shared.vanityDeepLink.isEmpty,
                   let vanityDeepLinkURL = URL(string: NotificationManager.shared.vanityDeepLink) {
                    
                    let cordialDeepLink = internalCordialAPI.getCordialDeepLink(url: vanityDeepLinkURL)
                    
                    CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(deepLink: cordialDeepLink, fallbackURL: nil, completionHandler: { deepLinkActionType in
                        
                        internalCordialAPI.deepLinkAction(deepLinkActionType: deepLinkActionType)
                    })
                } else {
                    let cordialDeepLink = internalCordialAPI.getCordialDeepLink(url: url)
                    
                    CordialSwiftUIDeepLinksPublisher.shared.publishDeepLink(deepLink: cordialDeepLink, fallbackURL: nil, completionHandler: { deepLinkActionType in
                        
                        internalCordialAPI.deepLinkAction(deepLinkActionType: deepLinkActionType)
                    })
                }
                
                NotificationManager.shared.vanityDeepLink = String()
                
                LoggerManager.shared.error(message: "Vanity DeepLink opening failed. Error: [\(error)]", category: "CordialSDKDeepLinks")
            })
        }
    }
}
