//
//  InboxMessageAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objc public class InboxMessageAPI: NSObject {
    
    @objc public func sendInboxMessageReadEvent(mcID: String) {
        let eventName = API.EVENT_NAME_INBOX_MESSAGE_READ
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
    }
    
    @objc public func fetchInboxMessagesOrigin() {
        if let primaryKey = CordialAPI().getContactPrimaryKey() {
            InboxMessagesGetter().fetchInboxMessagesOrigin(primaryKey: primaryKey)
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Fetching inbox messages failed. Error: [primaryKey is absent]", log: OSLog.cordialInboxMessages, type: .error)
            }
        }
    }
    
    @objc public func fetchInboxMessages(onComplete: @escaping (_ response: String) -> Void, onError: @escaping (_ error: String) -> Void) {
        if let primaryKey = CordialAPI().getContactPrimaryKey() {
            InboxMessagesGetter().fetchInboxMessages(primaryKey: primaryKey, onComplete: { response in
                onComplete(response)
            }, onError: { error in
                onError(error)
            })
        } else {
            let error = "Fetching inbox messages failed. Error: [primaryKey is absent]"
            onError(error)
        }
    }
}
