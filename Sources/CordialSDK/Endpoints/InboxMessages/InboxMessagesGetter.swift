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
    
    func fetchInboxMessages(pageRequest: PageRequest, inboxFilter: InboxFilter?, contactKey: String, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        
        let internalCordialAPI = InternalCordialAPI()
        
        if internalCordialAPI.isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                if internalCordialAPI.getCurrentJWT() != nil {
                    LoggerManager.shared.info(message: "Fetching inbox messages", category: "CordialSDKInboxMessages")
                    
                    InboxMessages().getInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, contactKey: contactKey, onSuccess: { response in
                        LoggerManager.shared.info(message: "Inbox messages have been received successfully", category: "CordialSDKInboxMessages")
                        
                        onSuccess(response)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                } else {
                    SDKSecurity.shared.updateJWTwithCallbacks(onSuccess: { response in
                        self.fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, contactKey: contactKey, onSuccess: onSuccess, onFailure: onFailure)
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
