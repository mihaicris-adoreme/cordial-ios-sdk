//
//  InboxMessagesMarkReadUnreadSender.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class InboxMessagesMarkReadUnreadSender {
    
    func sendInboxMessagesReadUnreadMarks() {
        if InternalCordialAPI().isUserLogin() {
            if ReachabilityManager.shared.isConnectedToInternet {
                
            } else {
                
            }
        } else {

        }
    }
}
