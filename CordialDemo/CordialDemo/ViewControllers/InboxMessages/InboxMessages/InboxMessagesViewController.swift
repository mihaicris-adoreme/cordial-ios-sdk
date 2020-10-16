//
//  InboxMessagesViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 15.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let inboxMessagesTableCell = "inboxMessagesTableCell"
    
    let segueToMessageIdentifier = "segueToMessage"
    
    var inboxMessages = [InboxMessage]()
    var chosenInboxMessage: InboxMessage!
    
    var isInboxMessagesHasBeenLoaded = false
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.title = "Inbox"
        
        self.setupNotificationNewInboxMessageDelivered()
        
        self.prepareActivityIndicator()
        self.updateTableViewData()
    }
    
    func getPageRequest() -> PageRequest {
        self.isInboxMessagesHasBeenLoaded = false
        
        return PageRequest(page: 1, size: 10)
    }
    
    func setupNotificationNewInboxMessageDelivered() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.removeObserver(self, name: .cordialDemoNewInboxMessageDelivered, object: nil)
        notificationCenter.addObserver(self, selector: #selector(newInboxMessageDelivered), name: .cordialDemoNewInboxMessageDelivered, object: nil)
    }

    @objc func newInboxMessageDelivered() {
        self.updateInboxMessages(pageRequest: self.getPageRequest())
    }
    
    func prepareActivityIndicator() {
        if #available(iOS 13.0, *) {
            self.activityIndicator.style = .large
        } else {
            self.activityIndicator.style = .gray
        }
        
        self.activityIndicator.hidesWhenStopped = true
        self.tableView.backgroundView = self.activityIndicator
    }
    
    func updateTableViewData() {
        if self.inboxMessages.isEmpty {
            self.activityIndicator.startAnimating()
        }
        
        self.updateInboxMessages(pageRequest: self.getPageRequest())
    }
    
    func tableViewReloadData() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func refreshTableViewData() {
        if self.isInboxMessagesHasBeenLoaded {
            self.inboxMessages = [InboxMessage]()
            self.tableView.reloadData()
            self.updateTableViewData()
        }
    }
    
    func updateInboxMessages(pageRequest: PageRequest) {
        CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, onSuccess: { inboxPage in
            if !self.isInboxMessagesHasBeenLoaded {
                self.inboxMessages += inboxPage.content
                self.tableViewReloadData()
            }
            
            if inboxPage.hasNext() {
                self.updateInboxMessages(pageRequest: pageRequest.next())
            } else {
                self.isInboxMessagesHasBeenLoaded = true
            }
        }, onFailure: { error in
            popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.refreshTableViewData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToMessageIdentifier:
            if let inboxMessageViewController = segue.destination as? InboxMessageViewController {
                
                if !self.chosenInboxMessage.isRead {
                    CordialInboxMessageAPI().markInboxMessagesRead(mcIDs: [self.chosenInboxMessage.mcID])
                    inboxMessageViewController.isNeededInboxMessagesUpdate = true
                } else {
                    inboxMessageViewController.isNeededInboxMessagesUpdate = false
                }
                
                CordialInboxMessageAPI().sendInboxMessageReadEvent(mcID: self.chosenInboxMessage.mcID)
                
                inboxMessageViewController.inboxMessage = self.chosenInboxMessage
            }
        default:
            break
        }
        
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.inboxMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.inboxMessagesTableCell, for: indexPath) as! InboxMessagesTableViewCell
        
        let inboxMessage = self.inboxMessages[indexPath.row]
        
        let timestamp = inboxMessage.sentAt
        let date = CordialDateFormatter().getDateFromTimestamp(timestamp: timestamp)!
        cell.timestampLabel.text = AppDateFormatter().getTimestampFromDate(date: date)
        
        if inboxMessage.isRead {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenInboxMessage = self.inboxMessages[indexPath.row]
        
        self.performSegue(withIdentifier: self.segueToMessageIdentifier, sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let inboxMessage = self.inboxMessages[indexPath.row]
            
            CordialInboxMessageAPI().deleteInboxMessage(mcID: inboxMessage.mcID)
            
            self.inboxMessages.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
}
