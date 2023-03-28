//
//  InboxMessageWebViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 11.05.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import UIKit
import WebKit
import CordialSDK

class InboxMessageWebViewController: UIViewController {
    
    @IBOutlet weak var inboxMessageContentWebView: WKWebView!
    
    var inboxMessage: InboxMessage!
    
    var isNeededInboxMessagesUpdate: Bool!
    
    let activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "mark_unread"), style: .plain, target: self, action: #selector(markUnreadButtonAction))
        
        self.prepareActivityIndicator()
        self.fetchInboxMessageContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate,
           let inboxMessagesViewController = self.previousViewController as? InboxMessagesTableListViewController {
            
            inboxMessagesViewController.refreshTableViewData()
            
        }
    }

    func prepareActivityIndicator() {
        if #available(iOS 13.0, *) {
            self.activityIndicator.style = .large
        } else {
            self.activityIndicator.style = .gray
        }
        
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center

        self.view.addSubview(self.activityIndicator)
    }
    
    @objc func markUnreadButtonAction() {
        CordialInboxMessageAPI().markInboxMessagesUnread(mcIDs: [self.inboxMessage.mcID])
        
        self.isNeededInboxMessagesUpdate = true
        
        App.popupSimpleNoteAlert(title: "Message marked as unread", message: nil, controller: self)
    }
    
    func fetchInboxMessageContent() {
        self.activityIndicator.startAnimating()
        
        CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.inboxMessage.mcID, onSuccess: { content in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                do {
                    if let contentData = content.data(using: .utf8),
                       let contentJSON = try JSONSerialization.jsonObject(with: contentData, options: []) as? [String: AnyObject],
                       let hrml = contentJSON["html"] as? String {
                        
                        self.inboxMessageContentWebView.loadHTMLString(hrml, baseURL: nil)
                    }
                } catch let error {
                    App.popupSimpleNoteAlert(title: error.localizedDescription, message: nil, controller: self)
                }
            }
        }, onFailure: { error in
            App.popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }

}
