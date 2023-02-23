//
//  CordialDeepLinksInternalData.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 04.01.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

class CordialDeepLinksInternalData {
    
    let id : String
    let url: URL
    
    init(id: String, url: URL) {
        self.id = id
        self.url = url
    }
}
