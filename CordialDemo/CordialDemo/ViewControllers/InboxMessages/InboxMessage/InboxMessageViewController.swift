//
//  InboxMessageViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 16.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessageViewController: UIViewController {
    
    @IBOutlet weak var messageContent: UITextView!
    
    var inboxMessage: InboxMessage!
    
    var isNeededInboxMessagesUpdate: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "mark_unread"), style: .plain, target: self, action: #selector(markUnreadButtonAction))
        
        self.messageContent.text = self.inboxMessage.url
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate, let inboxMessagesViewController = self.previousViewController as? InboxMessagesViewController {
            inboxMessagesViewController.clearTableViewData()
        }
    }
    
    @objc func markUnreadButtonAction() {
        CordialInboxMessageAPI().markInboxMessagesUnread(mcIDs: [self.inboxMessage.id])
        
        self.isNeededInboxMessagesUpdate = true
        
        popupSimpleNoteAlert(title: "Message marked as unread", message: nil, controller: self)
    }
    
}
