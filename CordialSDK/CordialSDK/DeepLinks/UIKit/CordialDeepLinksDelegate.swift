//
//  CordialDeepLinksDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 09.10.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol CordialDeepLinksDelegate {
    
    @objc func openDeepLink(url: URL, fallbackURL: URL?)
    
    @available(iOS 13.0, *)
    @objc func openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene)
    
}
