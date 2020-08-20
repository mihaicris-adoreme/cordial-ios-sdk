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
    
    func fetchInboxMessages(primaryKey: String) {
        if ReachabilityManager.shared.isConnectedToInternet {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching inbox messages with primaryKey: [%{public}@]", log: OSLog.cordialInboxMessages, type: .info, primaryKey)
            }
            
            if InternalCordialAPI().getCurrentJWT() != nil {
                InboxMessages().getInboxMessages(primaryKey: primaryKey)
            } else {
                let responseError = ResponseError(message: "JWT is absent", statusCode: nil, responseBody: nil, systemError: nil)
                self.systemErrorHandler(primaryKey: primaryKey, error: responseError)
                
                SDKSecurity.shared.updateJWT()
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [No Internet connection]", log: OSLog.cordialInboxMessages, type: .info, primaryKey)
            }
        }
    }
    
    func systemErrorHandler(primaryKey: String, error: ResponseError) {
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
            os_log("Fetching inbox messages with primaryKey: [%{public}@] failed. Error: [%{public}@]", log: OSLog.cordialInAppMessage, type: .info, primaryKey, error.message)
        }
    }
    
}
