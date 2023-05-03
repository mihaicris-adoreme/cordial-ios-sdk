//
//  LoggerDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol LoggerDelegate {
    
    @objc func log(_ message: String)
    @objc func info(_ message: String)
    @objc func debug(_ message: String)
    @objc func error(_ message: String)
    @objc func fault(_ message: String)

}
