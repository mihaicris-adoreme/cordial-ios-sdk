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
    
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    @IBOutlet weak var isReadSegmentedControl: UISegmentedControl!
    
    var inboxPageFilter: InboxPageFilter?
    
    var isNeededInboxMessagesUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Filter"
        
        self.fromDateTextField.setBottomBorder(color: UIColor.black)
        self.toDateTextField.setBottomBorder(color: UIColor.black)
        
        self.prepareInboxPageFilterData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate,
           let inboxMessagesViewController = self.previousViewController as? InboxMessagesViewController {
            inboxMessagesViewController.inboxPageFilter = self.inboxPageFilter
            inboxMessagesViewController.refreshTableViewData()
        }
    }
    
    @IBAction func fromDatePickerAction(_ sender: UIDatePicker) {
        self.isNeededInboxMessagesUpdate = true
        
        self.fromDateTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
        
        if let inboxPageFilter = self.inboxPageFilter {
            self.inboxPageFilter = InboxPageFilter(isRead: inboxPageFilter.isRead, fromDate: sender.date, toDate: inboxPageFilter.toDate)
        } else {
            self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: sender.date, toDate: nil)
        }
    }
    
    @IBAction func toDatePickerAction(_ sender: UIDatePicker) {
        self.isNeededInboxMessagesUpdate = true
        
        self.toDateTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
        
        if let inboxPageFilter = self.inboxPageFilter {
            self.inboxPageFilter = InboxPageFilter(isRead: inboxPageFilter.isRead, fromDate: inboxPageFilter.fromDate, toDate: sender.date)
        } else {
            self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: nil, toDate: sender.date)
        }
    }
    
    @IBAction func fromDateClearAction(_ sender: UIButton) {
        self.isNeededInboxMessagesUpdate = true
        
        self.fromDateTextField.text = nil
        
        if let inboxPageFilter = self.inboxPageFilter {
            self.inboxPageFilter = InboxPageFilter(isRead: inboxPageFilter.isRead, fromDate: nil, toDate: inboxPageFilter.toDate)
        } else {
            self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: nil, toDate: nil)
        }
    }
    
    @IBAction func toDateClearAction(_ sender: UIButton) {
        self.isNeededInboxMessagesUpdate = true
        
        self.toDateTextField.text = nil
        
        if let inboxPageFilter = self.inboxPageFilter {
            self.inboxPageFilter = InboxPageFilter(isRead: inboxPageFilter.isRead, fromDate: inboxPageFilter.fromDate, toDate: nil)
        } else {
            self.inboxPageFilter = InboxPageFilter(isRead: .NONE, fromDate: nil, toDate: nil)
        }
    }
    
    func prepareInboxPageFilterData() {
        if let inboxPageFilter = self.inboxPageFilter {
            self.isReadSegmentedControl.selectedSegmentIndex = inboxPageFilter.isRead.rawValue
            
            if let fromDate = inboxPageFilter.fromDate {
                self.fromDatePicker.date = fromDate
                self.fromDateTextField.text = AppDateFormatter().getTimestampFromDate(date: fromDate)
            }
            
            if let toDate = inboxPageFilter.toDate {
                self.toDatePicker.date = toDate
                self.toDateTextField.text = AppDateFormatter().getTimestampFromDate(date: toDate)
            }
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
