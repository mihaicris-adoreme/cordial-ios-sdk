//
//  ResponseError.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/21/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

public struct ResponseError {
    
    public let message: String
    public let statusCode: Int?
    public let responseBody: String?
    public let systemError: Error?
    
    init(message: String, statusCode: Int?, responseBody: String?, systemError: Error?) {
        self.message = message
        self.statusCode = statusCode
        self.responseBody = responseBody
        self.systemError = systemError
    }
}
