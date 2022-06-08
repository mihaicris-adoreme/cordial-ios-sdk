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
    
    func baseLogsOutput(url: URL, vanityURL: URL?, fallbackURL: URL?) {
        if let fallbackURL = fallbackURL {
            self.logsOutputWithFallbackURL(url: url, vanityURL: vanityURL, fallbackURL: fallbackURL)
        } else {
            self.logsOutputWithoutFallbackURL(url: url, vanityURL: vanityURL)
        }

    }
    
    private func logsOutputWithoutFallbackURL(url: URL, vanityURL: URL?) {
        if let vanityURL = vanityURL {
            os_log("DeepLink handler has been called \n url: %{public}@ \n vanityURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, vanityURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n url: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString)
        }
    }
    
    private func logsOutputWithFallbackURL(url: URL, vanityURL: URL?, fallbackURL: URL) {
        if let vanityURL = vanityURL {
            os_log("DeepLink handler has been called \n url: %{public}@ \n vanityURL: %{public}@ \n fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, vanityURL.absoluteString, fallbackURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n url: %{public}@ \n fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, fallbackURL.absoluteString)
        }
    }
}
