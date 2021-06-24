//
//  CordialSwiftUIAppDeepLinksPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 23.06.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class CordialSwiftUIAppDeepLinksPublisher: ObservableObject {
    
    public static let shared = CordialSwiftUIAppDeepLinksPublisher()
    
    private init() {}
    
    @Published public var deepLink: URL?
    
}

