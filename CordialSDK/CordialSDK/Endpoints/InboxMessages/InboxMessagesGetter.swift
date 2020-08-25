//
//  InboxMessagesGetter.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

class InboxMessagesGetter {
    
    func fetchInboxMessagesOrigin(primaryKey: String) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching inbox messages with primaryKey: [%{public}@]", log: OSLog.cordialInboxMessages, type: .info, primaryKey)
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                InboxMessages().getInboxMessagesOrigin(primaryKey: primaryKey)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.errorHandler(primaryKey: primaryKey, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [No Internet connection]", log: OSLog.cordialInboxMessages, type: .error, primaryKey)
            }
        }
    }
    
    func fetchInboxMessages(primaryKey: String, onComplete: @escaping (_ response: String) -> Void, onError: @escaping (_ error: String) -> Void) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching inbox messages with primaryKey: [%{public}@]", log: OSLog.cordialInboxMessages, type: .info, primaryKey)
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                InboxMessages().getInboxMessages(primaryKey: primaryKey, onComplete: { response in
                    onComplete(response)
                }, onError: { error in
                    onError(error)
                })
            } else {
                let error = "Fetching inbox messages with primaryKey: [\(primaryKey)] failed. Error: [JWT is absent]"
                onError(error)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            let error = "Fetching inbox messages with primaryKey: [\(primaryKey)] failed. Error: [No Internet connection]"
            onError(error)
        }
    }
    
    func completionHandler(primaryKey: String, responseBody: String) {
        print(responseBody)
    }
    
    func errorHandler(primaryKey: String, error: ResponseError) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [%{public}@]", log: OSLog.cordialInboxMessages, type: .error, primaryKey, error.message)
        }
    }
    
}
