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
    
    @objc public func fetchInboxMessages(onComplete: @escaping (_ response: [InboxMessage]) -> Void, onError: @escaping (_ error: String) -> Void) {
        let cordialAPI = CordialAPI()
        
        var key: String?
        if let primaryKey = cordialAPI.getContactPrimaryKey() {
            key = primaryKey
        } else if let token = InternalCordialAPI().getPushNotificationToken() {
            let channelKey = cordialAPI.getChannelKey()
            key = "\(channelKey):\(token)"
        }
        
        if let urlKey = key {
            InboxMessagesGetter().fetchInboxMessages(urlKey: urlKey, onComplete: { response in
                onComplete(response)
            }, onError: { error in
                onError(error)
            })
        } else {
            let error = "Fetching inbox messages failed. Error: [Unexpected error]"
            onError(error)
        }
    }
    
    @objc public func markInboxMessageRead(mcID: String) {
        let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [mcID], markAsUnreadMcIDs: [])
        InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
    }
    
    @objc public func markInboxMessageUnread(mcID: String) {
        let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [], markAsUnreadMcIDs: [mcID])
        InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
    }
}
