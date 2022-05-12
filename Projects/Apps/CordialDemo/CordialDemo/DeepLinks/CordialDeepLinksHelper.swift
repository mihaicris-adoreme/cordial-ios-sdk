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
    
    func baseLogsOutput(url: URL, encodedURL: URL?, fallbackURL: URL?) {
        if let fallbackURL = fallbackURL {
            self.logsOutputWithFallbackURL(url: url, encodedURL: encodedURL, fallbackURL: fallbackURL)
        } else {
            self.logsOutputWithoutFallbackURL(url: url, encodedURL: encodedURL)
        }

    }
    
    private func logsOutputWithoutFallbackURL(url: URL, encodedURL: URL?) {
        if let encodedURL = encodedURL {
            os_log("DeepLink handler has been called \n url: %{public}@ \n encodedURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, encodedURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n url: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString)
        }
    }
    
    private func logsOutputWithFallbackURL(url: URL, encodedURL: URL?, fallbackURL: URL) {
        if let encodedURL = encodedURL {
            os_log("DeepLink handler has been called \n url: %{public}@ \n encodedURL: %{public}@ \n fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, encodedURL.absoluteString, fallbackURL.absoluteString)
        } else {
            os_log("DeepLink handler has been called \n url: %{public}@ \n fallbackURL: %{public}@", log: OSLog.сordialSDKDemo, type: .info, url.absoluteString, fallbackURL.absoluteString)
        }
    }
}
