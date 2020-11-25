//
//  InboxMessagesTableViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 15.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let reuseIdentifier = "inboxMessagesTableCell"
    
    let segueToInboxMessageIdentifier = "segueFromInboxTableToInboxMessage"
    let segueToInboxFilterIdentifier = "segueFromInboxTableToInboxFilter"
    
    var inboxMessages = [InboxMessage]()
    var chosenInboxMessage: InboxMessage!
    
    var inboxFilter: InboxFilter?
    
    var isInboxMessagesHasBeenLoaded = false
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Inbox"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        let filterButton = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        navigationItem.rightBarButtonItems = [refreshButton, filterButton]
        
        self.prepareActivityIndicator()
        self.updateTableViewData()
    }
    
    @objc func filterAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToInboxFilterIdentifier, sender: self)
    }
    
    @objc func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.refreshTableViewData()
    }
    
    func refreshTableViewData() {
        if self.isInboxMessagesHasBeenLoaded {
            self.inboxMessages = [InboxMessage]()
            self.tableView.reloadData()
            self.updateTableViewData()
        }
    }
    
    func getNewPageRequest() -> PageRequest {
        self.isInboxMessagesHasBeenLoaded = false
        
        return PageRequest(page: 1, size: 10)
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
        
        self.updateInboxMessages(pageRequest: self.getNewPageRequest(), inboxFilter: self.inboxFilter)
    }
    
    func tableViewReloadData() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func updateInboxMessages(pageRequest: PageRequest, inboxFilter: InboxFilter?) {
        CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, onSuccess: { inboxPage in
            if !self.isInboxMessagesHasBeenLoaded {
                self.inboxMessages += inboxPage.content
                self.tableViewReloadData()
            }
            
            if inboxPage.hasNext() {
                self.updateInboxMessages(pageRequest: pageRequest.next(), inboxFilter: inboxFilter)
            } else {
                self.isInboxMessagesHasBeenLoaded = true
            }
        }, onFailure: { error in
            popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToInboxMessageIdentifier:
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
        case self.segueToInboxFilterIdentifier:
            if let inboxMessagesFilterViewController = segue.destination as? InboxMessagesFilterViewController {
                inboxMessagesFilterViewController.inboxFilter = self.inboxFilter
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
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! InboxMessagesTableViewCell
        
        let inboxMessage = self.inboxMessages[indexPath.row]
        
        cell.timestampLabel.text = AppDateFormatter().getTimestampFromDate(date: inboxMessage.sentAt)
        
        if inboxMessage.isRead {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chosenInboxMessage = self.inboxMessages[indexPath.row]
        
        self.performSegue(withIdentifier: self.segueToInboxMessageIdentifier, sender: self)
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
