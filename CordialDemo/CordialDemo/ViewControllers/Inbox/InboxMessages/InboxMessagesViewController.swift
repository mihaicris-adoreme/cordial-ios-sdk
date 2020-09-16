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
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.title = "Inbox"
        
        self.prepareActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.updateTableViewData()
    }
    
    func prepareActivityIndicator() {
        if #available(iOS 13.0, *) {
            self.activityIndicator.style = .large
        } else {
            self.activityIndicator.style = .gray
        }
        self.tableView.backgroundView = self.activityIndicator
    }
    
    func updateTableViewData() {
        self.activityIndicator.startAnimating()
        self.updateInboxMessages()
    }
    
    func tableViewReloadData() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
    
    func updateInboxMessages() {
        CordialInboxMessageAPI().fetchInboxMessages(onSuccess: { inboxMessages in
            self.inboxMessages = inboxMessages
            self.tableViewReloadData()
        }, onFailure: { error in
            popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    @IBAction func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.inboxMessages = [InboxMessage]()
        self.tableView.reloadData()
        
        self.updateTableViewData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToMessageIdentifier:
            if let inboxMessageViewController = segue.destination as? InboxMessageViewController {
                // TODO Navigation
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
        
        cell.titleLabel.text = inboxMessage.title
        
        let timestamp = self.inboxMessages[indexPath.row].sentAt
        let date = CordialDateFormatter().getDateFromTimestamp(timestamp: timestamp)!
        cell.timestampLabel.text = AppDateFormatter().getTimestampFromDate(date: date)
        
        if inboxMessage.read {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: self.segueToMessageIdentifier, sender: self)
    }
}
