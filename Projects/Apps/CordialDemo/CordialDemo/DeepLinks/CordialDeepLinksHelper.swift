//
//  CordialDeepLinksHelper.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 12.05.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import os.log

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
            os_log("DeepLink handler has been called [%{public}@] \n\t url: %{public}@ \n\t vanityURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, isSceneLog, url.absoluteString, vanityURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called [%{public}@] \n\t url: %{public}@", log: OSLog.сordialSDKDemo, type: .info, isSceneLog, url.absoluteString)
        }
    }
    
    private func logsOutputWithFallbackURL(isSceneLog: String, url: URL, vanityURL: URL?, fallbackURL: URL) {
        if let vanityURL = vanityURL {
            os_log("DeepLink handler has been called [%{public}@] \n\t url: %{public}@ \n\t vanityURL: %{public}@ \n\t fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, isSceneLog, url.absoluteString, vanityURL.absoluteString, fallbackURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called [%{public}@] \n\t url: %{public}@ \n\t fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, isSceneLog, url.absoluteString, fallbackURL.absoluteString)
        }
    }
}
