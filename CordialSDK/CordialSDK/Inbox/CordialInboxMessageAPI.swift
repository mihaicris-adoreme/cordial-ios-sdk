//
//  CordialInboxMessageAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import os.log

@objc public class CordialInboxMessageAPI: NSObject {
    
    @objc public func sendInboxMessageReadEvent(mcID: String) {
        let eventName = API.EVENT_NAME_INBOX_MESSAGE_READ
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
        
        InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        
    }
    
    @objc public func fetchInboxMessages(pageRequest: PageRequest, inboxPageFilter: InboxPageFilter?, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        if let contactKey = InternalCordialAPI().getContactKey() {
            InboxMessagesGetter().fetchInboxMessages(pageRequest: pageRequest, inboxPageFilter: inboxPageFilter, contactKey: contactKey, onSuccess: { response in
                onSuccess(response)
            }, onFailure: { error in
                onFailure(error)
            })
        } else {
            let error = "Fetching inbox messages failed. Error: [Unexpected error]"
            onFailure(error)
        }
    }
    
    @objc public func markInboxMessagesRead(mcIDs: [String]) {
        let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: mcIDs, markAsUnreadMcIDs: [])
        InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
    }
    
    @objc public func markInboxMessagesUnread(mcIDs: [String]) {
        let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [], markAsUnreadMcIDs: mcIDs)
        InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
    }
    
    @objc public func fetchInboxMessage(mcID: String, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        if let contactKey = InternalCordialAPI().getContactKey() {
            InboxMessageGetter().fetchInboxMessage(contactKey: contactKey, mcID: mcID, onSuccess: { response in
                onSuccess(response)
            }, onFailure: { error in
                onFailure(error)
            })
        } else {
            let error = "Fetching single inbox message failed. Error: [Unexpected error]"
            onFailure(error)
        }
    }
    
    @objc public func fetchInboxMessageContent(mcID: String, onSuccess: @escaping (_ response: String) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        self.fetchInboxMessage(mcID: mcID, onSuccess: { inboxMessage in
            if let url = URL(string: inboxMessage.url) {
                InboxMessageContentGetter().fetchInboxMessageContent(url: url, onSuccess: { response in
                    onSuccess(response)
                }, onFailure: { error in
                    onFailure(error)
                })
            } else {
                onFailure("Fetching inbox message content failed. Error: [Inbox message URL is not valid]")
            }
        }, onFailure: { error in
            onFailure(error)
        })
    }
    
    @objc public func deleteInboxMessage(mcID: String) {
        let inboxMessageDeleteRequest = InboxMessageDeleteRequest(mcID: mcID)
        InboxMessageDeleteSender().sendInboxMessageDelete(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
    }
}
