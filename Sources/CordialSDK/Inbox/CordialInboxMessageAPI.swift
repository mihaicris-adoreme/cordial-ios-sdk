//
//  CordialInboxMessageAPI.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 17.08.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class CordialInboxMessageAPI: NSObject {
    
    @objc public func sendInboxMessageReadEvent(mcID: String) {
        DispatchQueue.main.async {
            let eventName = API.EVENT_NAME_INBOX_MESSAGE_READ
            let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: CordialApiConfiguration.shared.systemEventsProperties)
            
            InternalCordialAPI().sendAnyCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
        }
    }
    
    @objc public func fetchInboxMessages(pageRequest: PageRequest, inboxFilter: InboxFilter? = nil, onSuccess: @escaping (_ response: InboxPage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        DispatchQueue.main.async {
            if let contactKey = InternalCordialAPI().getContactKey() {
                InboxMessagesGetter().fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, contactKey: contactKey, onSuccess: { response in
                    onSuccess(response)
                }, onFailure: { error in
                    onFailure(error)
                })
            } else {
                let error = "Fetching inbox messages failed. Error: [Unexpected error]"
                onFailure(error)
            }
        }
    }
    
    @objc public func markInboxMessagesRead(mcIDs: [String]) {
        DispatchQueue.main.async {
            let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: mcIDs, markAsUnreadMcIDs: [])
            InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        }
    }
    
    @objc public func markInboxMessagesUnread(mcIDs: [String]) {
        DispatchQueue.main.async {
            let inboxMessagesMarkReadUnreadRequest = InboxMessagesMarkReadUnreadRequest(markAsReadMcIDs: [], markAsUnreadMcIDs: mcIDs)
            InboxMessagesMarkReadUnreadSender().sendInboxMessagesReadUnreadMarks(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
        }
    }
    
    @available(*, deprecated, message: "Use fetchInboxMessages instead")
    @objc public func fetchInboxMessage(mcID: String, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
        DispatchQueue.main.async {
            if let inboxMessage = CoreDataManager.shared.inboxMessagesCache.getInboxMessageFromCoreData(mcID: mcID),
               API.isValidExpirationDate(date: inboxMessage.urlExpireAt) {
                onSuccess(inboxMessage)
            } else {
                self.getInboxMessage(mcID: mcID, onSuccess: { response in
                    onSuccess(response)
                }, onFailure: { error in
                    onFailure(error)
                })
            }
        }
    }
    
    internal func getInboxMessage(mcID: String, onSuccess: @escaping (_ response: InboxMessage) -> Void, onFailure: @escaping (_ error: String) -> Void) {
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
        DispatchQueue.main.async {
            if let content = CoreDataManager.shared.inboxMessagesContent.getInboxMessageContentFromCoreData(mcID: mcID) {
                onSuccess(content)
            } else {
                self.fetchInboxMessage(mcID: mcID, onSuccess: { inboxMessage in
                    if let url = URL(string: inboxMessage.url) {
                        InboxMessageContentGetter.shared.is400StatusReceived = false
                        InboxMessageContentGetter.shared.is403StatusReceived = false
                        InboxMessageContentGetter.shared.fetchInboxMessageContent(url: url, mcID: mcID, onSuccess: { response in
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
        }
    }
    
    @objc public func deleteInboxMessage(mcID: String) {
        DispatchQueue.main.async {
            CoreDataManager.shared.inboxMessagesCache.removeInboxMessageFromCoreData(mcID: mcID)
            CoreDataManager.shared.inboxMessagesContent.removeInboxMessageContentFromCoreData(mcID: mcID)
            
            let inboxMessageDeleteRequest = InboxMessageDeleteRequest(mcID: mcID)
            InboxMessageDeleteSender().sendInboxMessageDelete(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
        }
    }
}
