//
//  InboxMessageHandler.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 24.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CordialSDK

class InboxMessageHandler: InboxMessageDelegate {
    
    func newInboxMessageDelivered(mcID: String) {
        getActiveViewController()?.navigationController?.viewControllers.forEach({ viewController in
            if let inboxMessagesViewController = viewController as? InboxMessagesViewController {
                inboxMessagesViewController.updateInboxMessages()
            }
        })
    }

}
