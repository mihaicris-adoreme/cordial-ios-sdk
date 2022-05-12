//
//  CordialDeepLink.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.05.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialDeepLink: NSObject {
    
    let url: URL
    let encodedURL: URL?
    
    init(url: URL, encodedURL: URL?) {
        self.url = url
        self.encodedURL = encodedURL
    }
    
}
