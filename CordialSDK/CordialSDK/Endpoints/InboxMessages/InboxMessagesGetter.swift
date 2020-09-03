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
    
    func fetchInboxMessages(urlKey: String, onComplete: @escaping (_ response: [InboxMessage]) -> Void, onError: @escaping (_ error: String) -> Void) {
        
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching inbox messages", log: OSLog.cordialSDKInboxMessages, type: .info)
                }
                
                if InternalCordialAPI().getCurrentJWT() != nil {
                    InboxMessages().getInboxMessages(urlKey: urlKey, onComplete: { response in
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                            os_log("Inbox messages have been received successfully", log: OSLog.cordialSDKInboxMessages, type: .info)
                        }
                        
                        onComplete(response)
                    }, onError: { error in
                        onError(error)
                    })
                } else {
                    SDKSecurity.shared.updateJWTwithCallbacks(onComplete: { response in
                        self.fetchInboxMessages(urlKey: urlKey, onComplete: onComplete, onError: onError)
                    }, onError: { error in
                        onError(error)
                    })
                }
            } else {
                let error = "Fetching inbox messages failed. Error: [No Internet connection]"
                onError(error)
            }
        } else {
            let error = "Fetching inbox messages failed. Error: [User no login]"
            onError(error)
        }
    }
    
}
