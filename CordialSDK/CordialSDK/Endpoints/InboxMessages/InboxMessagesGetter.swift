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
                SDKSecurity.shared.updateJWTwithCallbacks(onComplete: { response in
                    self.fetchInboxMessages(primaryKey: primaryKey, onComplete: onComplete, onError: onError)
                }, onError: { error in
                    onError(error)
                })
            }
        } else {
            let error = "Fetching inbox messages with primaryKey: [\(primaryKey)] failed. Error: [No Internet connection]"
            onError(error)
        }
    }
    
}
