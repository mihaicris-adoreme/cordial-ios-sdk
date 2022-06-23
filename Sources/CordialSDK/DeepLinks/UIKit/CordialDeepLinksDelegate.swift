//
//  CordialDeepLinksDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

@objc public protocol CordialDeepLinksDelegate {
    
    @objc func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, completionHandler: @escaping (CordialDeepLinkActionType) -> Void)
    
    @available(iOS 13.0, *)
    @objc func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, scene: UIScene, completionHandler: @escaping (CordialDeepLinkActionType) -> Void)
    
}
