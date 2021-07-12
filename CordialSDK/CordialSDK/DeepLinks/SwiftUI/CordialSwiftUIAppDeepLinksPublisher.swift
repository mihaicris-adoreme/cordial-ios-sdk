//
//  CordialSwiftUIAppDeepLinksPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

@available(iOS 13.0, *)
public class CordialSwiftUIAppDeepLinksPublisher: ObservableObject {

    public static let shared = CordialSwiftUIAppDeepLinksPublisher()

    private init() {}
    
    public let deepLinks = PassthroughSubject<CordialSwiftUIAppDeepLinks, Never>()
    
    func publishDeepLink(url: URL, fallbackURL: URL?) {
        let deepLinks = CordialSwiftUIAppDeepLinks(url: url, fallbackURL: fallbackURL)
        
        self.deepLinks.send(deepLinks)
    }
}
