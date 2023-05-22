//
//  LoggerDelegate.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.05.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation

@objc public protocol LoggerDelegate {
    
    @objc func log(message: String, category: String)
    @objc func info(message: String, category: String)
    @objc func debug(message: String, category: String)
    @objc func error(message: String, category: String)
    @objc func fault(message: String, category: String)

}
