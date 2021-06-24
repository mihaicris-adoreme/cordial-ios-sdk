//
//  DeepLinksHandler.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 15.06.2021.
//

import Foundation
import CordialSDK

class DeepLinksHandler: CordialDeepLinksDelegate {
    
    func openDeepLink(url: URL, fallbackURL: URL?) {
        print(url.absoluteString)
    }
    
    func openDeepLink(url: URL, fallbackURL: URL?, scene: UIScene) {
        CordialSwiftUIAppDeepLinksPublisher.shared.deepLink = url
    }
    
}
