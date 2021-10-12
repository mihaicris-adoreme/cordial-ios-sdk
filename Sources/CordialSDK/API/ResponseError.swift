//
//  ResponseError.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 3/21/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class ResponseError: NSObject {
    
    @objc public let message: String
    public let statusCode: Int?
    @objc public let responseBody: String?
    @objc public let systemError: Error?
    
    @objc public convenience init(message: String, statusCodeNumber: NSNumber?, responseBody: String?, systemError: Error?) {
        self.init(message: message, statusCode: statusCodeNumber?.intValue, responseBody: responseBody, systemError: systemError)
    }
    
    public init(message: String, statusCode: Int?, responseBody: String?, systemError: Error?) {
        self.message = message
        self.statusCode = statusCode
        self.responseBody = responseBody
        self.systemError = systemError
    }
}
