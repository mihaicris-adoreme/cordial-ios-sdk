//
//  InboxMessagesFilterViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 20.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesFilterViewController: UIViewController {
    
    @IBOutlet weak var isReadSegmentedControl: UISegmentedControl!
    
    var inboxPageFilter: InboxPageFilter?
    
    var isNeededInboxMessagesUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Filter"
        
        self.prepareIsReadSegmentedControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate,
           let inboxMessagesViewController = self.previousViewController as? InboxMessagesViewController {
            inboxMessagesViewController.inboxPageFilter = self.inboxPageFilter
            inboxMessagesViewController.refreshTableViewData()
        }
    }
    
    func prepareIsReadSegmentedControl() {
        if let inboxPageFilter = self.inboxPageFilter {
            self.isReadSegmentedControl.selectedSegmentIndex = inboxPageFilter.isRead.rawValue
        }
    }

    @IBAction func isReadSegmentedControlAction(_ sender: UISegmentedControl) {
        self.isNeededInboxMessagesUpdate = true
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            if let inboxPageFilter = self.inboxPageFilter {
                self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: inboxPageFilter.fromDate, toDate: inboxPageFilter.toDate)
            } else {
                self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: nil, toDate: nil)
            }
        case 1:
            if let inboxPageFilter = self.inboxPageFilter {
                self.inboxPageFilter = InboxPageFilter(isRead: .YES, fromDate: inboxPageFilter.fromDate, toDate: inboxPageFilter.toDate)
            } else {
                self.inboxPageFilter = InboxPageFilter(isRead: .YES, fromDate: nil, toDate: nil)
            }
        case 2:
            if let inboxPageFilter = self.inboxPageFilter {
                self.inboxPageFilter = InboxPageFilter(isRead: .NO, fromDate: inboxPageFilter.fromDate, toDate: inboxPageFilter.toDate)
            } else {
                self.inboxPageFilter = InboxPageFilter(isRead: .NO, fromDate: nil, toDate: nil)
            }
        default: break
        }
    }
    
}
