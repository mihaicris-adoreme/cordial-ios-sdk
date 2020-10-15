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
    
    func fetchInboxMessagesPagination(pageRequest: PageRequest, contactKey: String, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching inbox messages", log: OSLog.cordialInboxMessages, type: .info)
                }
                
                if internalCordialAPI.getCurrentJWT() != nil {
                    InboxMessages().getInboxMessagesPagination(pageRequest: pageRequest, contactKey: contactKey, onSuccess: { response in
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                            os_log("Inbox messages have been received successfully", log: OSLog.cordialInboxMessages, type: .info)
                        }
                        
                        onSuccess(response)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                } else {
                    SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                        self.fetchInboxMessagesPagination(pageRequest: pageRequest, contactKey: contactKey, onSuccess: onSuccess, onFailure: onFailure)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                }
            } else {
                let error = "Fetching inbox messages failed. Error: [No Internet connection]"
                onFailure(error)
            }
        } else {
            let error = "Fetching inbox messages failed. Error: [User no login]"
            onFailure(error)
        }
    }

    
    func fetchInboxMessages(contactKey: String, onSuccess: @escaping (_ response: [InboxMessage]) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Fetching inbox messages", log: OSLog.cordialInboxMessages, type: .info)
                }
                
                if internalCordialAPI.getCurrentJWT() != nil {
                    InboxMessages().getInboxMessages(contactKey: contactKey, onSuccess: { response in
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                            os_log("Inbox messages have been received successfully", log: OSLog.cordialInboxMessages, type: .info)
                        }
                        
                        onSuccess(response)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                } else {
                    SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                        self.fetchInboxMessages(contactKey: contactKey, onSuccess: onSuccess, onFailure: onFailure)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                }
            } else {
                let error = "Fetching inbox messages failed. Error: [No Internet connection]"
                onFailure(error)
            }
        } else {
            let error = "Fetching inbox messages failed. Error: [User no login]"
            onFailure(error)
        }
    }
    
}
