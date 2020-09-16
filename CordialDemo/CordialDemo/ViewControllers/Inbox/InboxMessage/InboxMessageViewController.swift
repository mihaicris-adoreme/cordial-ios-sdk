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

    @IBOutlet weak var inboxMessageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var inboxMessageHTMLView: UIView!
    @IBOutlet weak var inboxMessageKeyValuePairsView: UIView!
    
    var inboxMessage: InboxMessage!
    
    var isNeededInboxMessagesUpdate: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "mark_unread"), style: .plain, target: self, action: #selector(markUnreadButtonAction))
        
        self.prepareInboxMessageSegmentedControl()
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
    
    func prepareInboxMessageSegmentedControl() {
        if let font = UIFont(name: "Copperplate", size: 16) {
            let underlineStyleNumber = NSNumber(integerLiteral: 1)
            let notUnderlineStyleNumber = NSNumber(integerLiteral: 0)
            let normalTextAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: font, NSAttributedString.Key.underlineStyle: notUnderlineStyleNumber] as! [NSAttributedString.Key: Any]
            let selectedTextAttributes = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.black, NSAttributedString.Key.font: font, NSAttributedString.Key.underlineStyle: underlineStyleNumber] as! [NSAttributedString.Key: Any]
            
            self.inboxMessageSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
            self.inboxMessageSegmentedControl.setTitleTextAttributes(selectedTextAttributes, for: .selected)
            self.inboxMessageSegmentedControl.backgroundColor = UIColor.white
            self.inboxMessageSegmentedControl.tintColor = UIColor.white
        }
    }
    
    @IBAction func inboxMessageSegmentedControlAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.inboxMessageHTMLView.isHidden = false
            self.inboxMessageKeyValuePairsView.isHidden = true
            break
        case 1:
            self.inboxMessageHTMLView.isHidden = true
            self.inboxMessageKeyValuePairsView.isHidden = false
            break
        default:
            break
        }
    }
    
}
