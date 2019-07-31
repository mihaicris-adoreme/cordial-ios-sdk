//
//  ResponseError.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/21/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

struct ResponseError {
    
    let message: String
    let statusCode: Int?
    let responseBody: String?
    let systemError: Error?
    
    init(message: String, statusCode: Int?, responseBody: String?, systemError: Error?) {
        self.message = message
        self.statusCode = statusCode
        self.responseBody = responseBody
        self.systemError = systemError
    }
}
