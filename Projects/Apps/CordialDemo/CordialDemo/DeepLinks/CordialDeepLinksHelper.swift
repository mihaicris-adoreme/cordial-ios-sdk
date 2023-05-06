//
//  CordialDeepLinksHelper.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 12.05.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class CordialDeepLinksHelper {
    
    func baseLogsOutput(isScene: Bool, url: URL, vanityURL: URL?, fallbackURL: URL?) {
        let isSceneLog = isScene ? "scenes-enabled" : "scenes-disabled"
        
        if let fallbackURL = fallbackURL {
            self.logsOutputWithFallbackURL(isSceneLog: isSceneLog, url: url, vanityURL: vanityURL, fallbackURL: fallbackURL)
        } else {
            self.logsOutputWithoutFallbackURL(isSceneLog: isSceneLog, url: url, vanityURL: vanityURL)
        }

    }
    
    private func logsOutputWithoutFallbackURL(isSceneLog: String, url: URL, vanityURL: URL?) {
        if let vanityURL = vanityURL {
            LoggerManager.shared.info(message: "DeepLink handler has been called [\(isSceneLog)] \n\t url: \(url.absoluteString) \n\t vanityURL: \(vanityURL.absoluteString)", category: "CordialSDKDemo")
        } else {
            LoggerManager.shared.info(message: "DeepLink handler has been called [\(isSceneLog)] \n\t url: \(url.absoluteString)", category: "CordialSDKDemo")
        }
    }
    
    private func logsOutputWithFallbackURL(isSceneLog: String, url: URL, vanityURL: URL?, fallbackURL: URL) {
        if let vanityURL = vanityURL {
            LoggerManager.shared.info(message: "DeepLink handler has been called [\(isSceneLog)] \n\t url: \(url.absoluteString) \n\t vanityURL: \(vanityURL.absoluteString) \n\t fallbackURL: \(fallbackURL.absoluteString)", category: "CordialSDKDemo")
        } else {
            LoggerManager.shared.info(message: "DeepLink handler has been called [\(isSceneLog)] \n\t url: \(url.absoluteString) \n\t fallbackURL: \(fallbackURL.absoluteString)", category: "CordialSDKDemo")
        }
    }
}
