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
                os_log("Universal link opening failed with error: [%{public}@]", log: OSLog.cordialError, type: .error, error)
            }
        })
    }
    
    private func fetchDeepLink(url: URL, onSuccess: @escaping (_ response: URL) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                onFailure("Fetching inbox messages failed. Error: [\(error.localizedDescription)]")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               let responseURL = httpResponse.url{
                
                switch httpResponse.statusCode {
                case 200:
                    onSuccess(responseURL)
                default:
                    let message = "Status code: \(httpResponse.statusCode). Description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                    
                    onFailure("Fetching inbox messages failed. \(message)")
                }
            } else {
                onFailure("Fetching inbox messages failed. Error: [Payload is absent]")
            }
        }.resume()
    }
    
}
