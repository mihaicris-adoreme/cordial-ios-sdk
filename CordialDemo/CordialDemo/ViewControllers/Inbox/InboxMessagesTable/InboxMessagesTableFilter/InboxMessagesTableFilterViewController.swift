//
//  InboxMessagesTableFilterViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 20.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesTableFilterViewController: UIViewController {
    
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var toDatePicker: UIDatePicker!
    
    @IBOutlet weak var isReadSegmentedControl: UISegmentedControl!
    
    var inboxFilter: InboxFilter?
    
    var isNeededInboxMessagesUpdate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Filter"
        
        self.fromDateTextField.setBottomBorder(color: UIColor.black)
        self.toDateTextField.setBottomBorder(color: UIColor.black)
        
        self.prepareInboxFilterData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate,
           let inboxMessagesViewController = self.previousViewController as? InboxMessagesTableViewController {
            inboxMessagesViewController.inboxFilter = self.inboxFilter
            inboxMessagesViewController.refreshTableViewData()
        }
    }
    
    @IBAction func fromDatePickerAction(_ sender: UIDatePicker) {
        self.isNeededInboxMessagesUpdate = true
        
        self.fromDateTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
        
        if let inboxFilter = self.inboxFilter {
            self.inboxFilter = InboxFilter(isRead: inboxFilter.isRead, fromDate: sender.date, toDate: inboxFilter.toDate)
        } else {
            self.inboxFilter = InboxFilter(isRead: .none, fromDate: sender.date, toDate: nil)
        }
    }
    
    @IBAction func toDatePickerAction(_ sender: UIDatePicker) {
        self.isNeededInboxMessagesUpdate = true
        
        self.toDateTextField.text = AppDateFormatter().getTimestampFromDate(date: sender.date)
        
        if let inboxFilter = self.inboxFilter {
            self.inboxFilter = InboxFilter(isRead: inboxFilter.isRead, fromDate: inboxFilter.fromDate, toDate: sender.date)
        } else {
            self.inboxFilter = InboxFilter(isRead: .none, fromDate: nil, toDate: sender.date)
        }
    }
    
    @IBAction func fromDateClearAction(_ sender: UIButton) {
        self.isNeededInboxMessagesUpdate = true
        
        self.fromDateTextField.text = nil
        
        if let inboxFilter = self.inboxFilter {
            self.inboxFilter = InboxFilter(isRead: inboxFilter.isRead, fromDate: nil, toDate: inboxFilter.toDate)
        } else {
            self.inboxFilter = InboxFilter(isRead: .none, fromDate: nil, toDate: nil)
        }
    }
    
    @IBAction func toDateClearAction(_ sender: UIButton) {
        self.isNeededInboxMessagesUpdate = true
        
        self.toDateTextField.text = nil
        
        if let inboxFilter = self.inboxFilter {
            self.inboxFilter = InboxFilter(isRead: inboxFilter.isRead, fromDate: inboxFilter.fromDate, toDate: nil)
        } else {
            self.inboxFilter = InboxFilter(isRead: .none, fromDate: nil, toDate: nil)
        }
    }
    
    func prepareInboxFilterData() {
        if let inboxFilter = self.inboxFilter {
            self.isReadSegmentedControl.selectedSegmentIndex = inboxFilter.isRead.rawValue
            
            if let fromDate = inboxFilter.fromDate {
                self.fromDatePicker.date = fromDate
                self.fromDateTextField.text = AppDateFormatter().getTimestampFromDate(date: fromDate)
            }
            
            if let toDate = inboxFilter.toDate {
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
            if let inboxFilter = self.inboxFilter {
                self.inboxFilter = InboxFilter(isRead: .none, fromDate: inboxFilter.fromDate, toDate: inboxFilter.toDate)
            } else {
                self.inboxFilter = InboxFilter(isRead: .none, fromDate: nil, toDate: nil)
            }
        case 1:
            if let inboxFilter = self.inboxFilter {
                self.inboxFilter = InboxFilter(isRead: .yes, fromDate: inboxFilter.fromDate, toDate: inboxFilter.toDate)
            } else {
                self.inboxFilter = InboxFilter(isRead: .yes, fromDate: nil, toDate: nil)
            }
        case 2:
            if let inboxFilter = self.inboxFilter {
                self.inboxFilter = InboxFilter(isRead: .no, fromDate: inboxFilter.fromDate, toDate: inboxFilter.toDate)
            } else {
                self.inboxFilter = InboxFilter(isRead: .no, fromDate: nil, toDate: nil)
            }
        default: break
        }
    }
    
}
