//
//  DependencyConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.02.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

@objc public class DependencyConfiguration: NSObject {
    
    @objc public static let shared = DependencyConfiguration()
    
    private override init(){}
    
    // MARK: Request Sender Init
    
    var requestSender = RequestSender()
    
    // MARK: URLSession Init
    
    var inboxMessagesURLSession = InboxMessagesURLSession().session
    var inboxMessageURLSession = InboxMessageURLSession().session
    var inboxMessageContentURLSession = InboxMessageContentURLSession().session
    
    // MARK: Get Custom Event JSON
    
    @objc public func getCustomEventJSON(eventName: String, properties: Dictionary<String, String>?) -> String {
        let mcID = CordialAPI().getCurrentMcID()
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, mcID: mcID, properties: properties)
        
        let sendCustomEvents = SendCustomEvents()
        
        return sendCustomEvents.getSendCustomEventJSON(sendCustomEventRequest: sendCustomEventRequest)
    }
    
}
