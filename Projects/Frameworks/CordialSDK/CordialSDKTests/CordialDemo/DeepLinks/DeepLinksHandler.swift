//
//  DeepLinksHandler.swift
//  CordialSDKTests
//
//  Created by Yan Malinovsky on 04.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class DeepLinksHandler: CordialDeepLinksDelegate {
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        // do nothing
    }
    
    @available(iOS 13.0, *)
    func openDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, scene: UIScene, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        // do nothing
    }
    
}
