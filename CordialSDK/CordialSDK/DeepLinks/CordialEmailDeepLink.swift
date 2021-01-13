//
//  CordialEmailDeepLink.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.01.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import os.log

class CordialEmailDeepLink {
    
    func open(url: URL) {
        self.fetchDeepLink(url: url, onSuccess: { url in
            InternalCordialAPI().openDeepLink(url: url)
        }, onFailure: { error in
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Email DeepLink opening failed. Error: [%{public}@]", log: OSLog.cordialError, type: .error, error)
            }
        })
    }
    
    private func fetchDeepLink(url: URL, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        CordialEmailDeepLinkURLSession().session.dataTask(with: url) { data, response, error in
            if let error = error {
                onFailure("Fetching Email DeepLink failed. Error: [\(error.localizedDescription)]")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 302,
                   let location = httpResponse.allHeaderFields["Location"] as? String,
                   let url = URL(string: location) {
                    
                    onSuccess(url)
                } else {
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    
                    onFailure("Fetching Email DeepLink failed. \(message)")
                }
            } else {
                onFailure("Fetching Email DeepLink failed. Error: [Unexpected error]")
            }
        }.resume()
    }
    
}
