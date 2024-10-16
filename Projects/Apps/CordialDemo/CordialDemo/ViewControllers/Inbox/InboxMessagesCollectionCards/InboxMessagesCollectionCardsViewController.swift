//
//  InboxMessagesCollectionCardsViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesCollectionCardsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "inboxMessagesCollectionCardsCell"
    
    let segueToInboxFilterIdentifier = "segueFromInboxCollectionCardsToInboxFilter"
    
    var inboxMessages = [InboxMessage]()
    
    var inboxFilter: InboxFilter?
    
    var isInboxMessagesHasBeenLoaded = false
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Inbox"
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let filterButton = UIBarButtonItem(image: UIImage(named: "filter"), style: .plain, target: self, action: #selector(filterAction))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshButtonAction))
        navigationItem.rightBarButtonItems = [refreshButton, filterButton]
        
        self.prepareActivityIndicator()
        self.updateСollectionViewData()
    }
    
    @objc func filterAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToInboxFilterIdentifier, sender: self)
    }
    
    @objc func refreshButtonAction(_ sender: UIBarButtonItem) {
        self.inboxMessages.forEach { inboxMessage in
            self.cancelTask(inboxMessage: inboxMessage)
        }
        
        self.refreshCollectionViewData()
    }
    
    func cancelTask(inboxMessage: InboxMessage) {
        if let inboxMessageMetadata = App.getInboxMessageMetadata(inboxMessage: inboxMessage),
           let inboxMessageMetadataData = inboxMessageMetadata.data(using: .utf8),
           let inboxMessageMetadataJSON = try? JSONSerialization.jsonObject(with: inboxMessageMetadataData, options: []) as? [String: String] {
            
            if let imageUrl = inboxMessageMetadataJSON["imageUrl"],
               let imageURL = URL(string: imageUrl) {
                
                App.cancelTask(imageURL)
            }
        }
    }
    
    func refreshCollectionViewData() {
        if self.isInboxMessagesHasBeenLoaded {
            self.inboxMessages = [InboxMessage]()
            self.collectionView.reloadData()
            self.updateСollectionViewData()
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
        self.collectionView.backgroundView = self.activityIndicator
    }
    
    func updateСollectionViewData() {
        if self.inboxMessages.isEmpty {
            self.activityIndicator.startAnimating()
        }
        
        self.updateInboxMessages(pageRequest: self.getNewPageRequest(), inboxFilter: self.inboxFilter)
    }
    
    func collectionViewReloadData() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.collectionView.reloadData()
        }
    }
    
    func updateInboxMessages(pageRequest: PageRequest, inboxFilter: InboxFilter?) {
        CordialInboxMessageAPI().fetchInboxMessages(pageRequest: pageRequest, inboxFilter: inboxFilter, onSuccess: { inboxPage in
            if !self.isInboxMessagesHasBeenLoaded {
                self.inboxMessages += inboxPage.content
                self.collectionViewReloadData()
            }
            
            if inboxPage.hasNext() {
                self.updateInboxMessages(pageRequest: pageRequest.next(), inboxFilter: inboxFilter)
            } else {
                self.isInboxMessagesHasBeenLoaded = true
            }
        }, onFailure: { error in
            App.popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    func openInboxMessageDeepLink(inboxMessage: InboxMessage) {
        CordialAPI().setCurrentMcID(mcID: inboxMessage.mcID)
        CordialInboxMessageAPI().sendInboxMessageReadEvent(mcID: inboxMessage.mcID)
        
        do {
            if let inboxMessageMetadata = App.getInboxMessageMetadata(inboxMessage: inboxMessage),
               let inboxMessageMetadataData = inboxMessageMetadata.data(using: .utf8), let inboxMessageMetadataJSON = try JSONSerialization.jsonObject(with: inboxMessageMetadataData, options: []) as? [String: String] {
                
                if let deepLink = inboxMessageMetadataJSON["deepLink"],
                   let deepLinkURL = URL(string: deepLink) {
                    
                    CordialAPI().openDeepLink(url: deepLinkURL)
                } else {
                    App.popupSimpleNoteAlert(title: "No deep link associated with this card", message: nil, controller: self)
                }
            } else {
                App.popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID)", controller: self)
            }
        } catch let error {
            App.popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID) Error: \(error.localizedDescription)", controller: self)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToInboxFilterIdentifier:
            if let inboxMessagesFilterViewController = segue.destination as? InboxMessagesFilterViewController {
                inboxMessagesFilterViewController.inboxFilter = self.inboxFilter
            }
        default:
            break
        }
    }

    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inboxMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! InboxMessagesCollectionCardsViewCell
        
        cell.imageViewActivityIndicator.startAnimating()
        
        cell.inboxMessageView.layer.shadowColor = UIColor.gray.cgColor
        cell.inboxMessageView.layer.shadowOpacity = 1
        cell.inboxMessageView.layer.shadowOffset = .zero
        cell.inboxMessageView.layer.shadowRadius = 3
        cell.inboxMessageView.layer.cornerRadius = 10
        
        let inboxMessage = self.inboxMessages[indexPath.row]
        
        do {
            if let inboxMessageMetadata = App.getInboxMessageMetadata(inboxMessage: inboxMessage),
               let inboxMessageMetadataData = inboxMessageMetadata.data(using: .utf8), let inboxMessageMetadataJSON = try JSONSerialization.jsonObject(with: inboxMessageMetadataData, options: []) as? [String: String] {
                
                if let image = inboxMessageMetadataJSON["imageUrl"], let imageURL = URL(string: image) {
                    DispatchQueue.main.async {
                        cell.imageView.asyncImage(url: imageURL)
                    }
                    cell.imageView.contentMode = .scaleAspectFill
                    cell.imageView.clipsToBounds = true
                    cell.imageView.layer.cornerRadius = 10
                }
                
                cell.titleLabel.text = inboxMessageMetadataJSON["title"]
                cell.subtitleLabel.text = inboxMessageMetadataJSON["subtitle"]
                
            } else {
                App.popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID)", controller: self)
            }
        } catch let error {
            App.popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID) Error: \(error.localizedDescription)", controller: self)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let inboxMessage = self.inboxMessages[indexPath.row]
        
        self.openInboxMessageDeepLink(inboxMessage: inboxMessage)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        DispatchQueue.main.async {
            if let indexPath = context.previouslyFocusedIndexPath {
                let inboxMessage = self.inboxMessages[indexPath.row]
                
                self.cancelTask(inboxMessage: inboxMessage)
            }
            
            if let indexPath = context.nextFocusedIndexPath {
                let inboxMessage = self.inboxMessages[indexPath.row]
                
                self.cancelTask(inboxMessage: inboxMessage)
            }
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width
        
        let cellHeight = cellWidth * 0.75 // 240 (height) / 320 (width) = 0.75
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}
