//
//  DeepLinksHelper.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 16.05.2022.
//

import Foundation
import CordialSDK
import os.log

struct DeepLinksHelper {
    
    func baseLogsOutput(url: URL, vanityURL: URL?, fallbackURL: URL?) {
        if let fallbackURL = fallbackURL {
            self.logsOutputWithFallbackURL(url: url, vanityURL: vanityURL, fallbackURL: fallbackURL)
        } else {
            self.logsOutputWithoutFallbackURL(url: url, vanityURL: vanityURL)
        }

    }
    
    private func logsOutputWithoutFallbackURL(url: URL, vanityURL: URL?) {
        if let vanityURL = vanityURL {
            os_log("DeepLink handler has been called \n\t url: %{public}@ \n\t vanityURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, vanityURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n\t url: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString)
        }
    }
    
    private func logsOutputWithFallbackURL(url: URL, vanityURL: URL?, fallbackURL: URL) {
        if let vanityURL = vanityURL {
            os_log("DeepLink handler has been called \n\t url: %{public}@ \n\t vanityURL: %{public}@ \n\t fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, vanityURL.absoluteString, fallbackURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n\t url: %{public}@ \n\t fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, fallbackURL.absoluteString)
        }
    }
    
}
