//
//  CordialDeepLink.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.05.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialDeepLink: NSObject {
    
    public let url: URL
    public let vanityURL: URL?
    
    init(url: URL, vanityURL: URL?) {
        self.url = url
        self.vanityURL = vanityURL
    }
    
}
