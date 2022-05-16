//
//  CordialSwiftUIDeepLinksPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIDeepLinksPublisher: ObservableObject {

    public static let shared = CordialSwiftUIDeepLinksPublisher()

    private init() {}
    
    public let deepLinks = PassthroughSubject<CordialSwiftUIDeepLinks, Never>()
    
    func publishDeepLink(deepLink: CordialDeepLink, fallbackURL: URL?, completionHandler: @escaping (CordialDeepLinkActionType) -> Void) {
        let deepLinks = CordialSwiftUIDeepLinks(deepLink: deepLink, fallbackURL: fallbackURL, completionHandler: completionHandler)
        
        self.deepLinks.send(deepLinks)
    }
}
