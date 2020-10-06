//
//  InboxMessageViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 16.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import WebKit
import CordialSDK

class InboxMessageViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    var inboxMessage: InboxMessage!
    
    var isNeededInboxMessagesUpdate: Bool!
    
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Message"
        
        self.webView.navigationDelegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "mark_unread"), style: .plain, target: self, action: #selector(markUnreadButtonAction))
        
        self.prepareActivityIndicator()
        self.fetchInboxMessageContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isNeededInboxMessagesUpdate, let inboxMessagesViewController = self.previousViewController as? InboxMessagesViewController {
            inboxMessagesViewController.clearTableViewData()
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
        
        popupSimpleNoteAlert(title: "Message marked as unread", message: nil, controller: self)
    }
    
    func fetchInboxMessageContent() {
        self.activityIndicator.startAnimating()
        
        CordialInboxMessageAPI().fetchInboxMessageContent(mcID: self.inboxMessage.mcID, onSuccess: { html in
            DispatchQueue.main.async {
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }, onFailure: { error in
            popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    // MARK: WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.activityIndicator.stopAnimating()
    }
}
