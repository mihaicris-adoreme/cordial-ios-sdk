//
//  InboxMessagesCollectionViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "inboxMessagesCollectionCell"
    
    var inboxMessages = [InboxMessage]()
    
    var inboxFilter: InboxFilter?
    
    var isInboxMessagesHasBeenLoaded = false
    let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Inbox"
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.prepareActivityIndicator()
        self.updateСollectionViewData()
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
            popupSimpleNoteAlert(title: error, message: nil, controller: self)
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }


    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inboxMessages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! InboxMessagesCollectionViewCell
        
        let inboxMessage = self.inboxMessages[indexPath.row]
        
        do {
            if let inboxMessageMetadataData = inboxMessage.metadata.data(using: .utf8), let inboxMessageMetadataJSON = try JSONSerialization.jsonObject(with: inboxMessageMetadataData, options: []) as? [String: String] {
                
                if let image = inboxMessageMetadataJSON["url"], let imageURL = URL(string: image) {
                    cell.imageView.asyncImage(url: imageURL)
                    cell.imageView.contentMode = .scaleAspectFill
                    cell.imageView.clipsToBounds = true
                    cell.imageView.layer.cornerRadius = 20
                }
                
                cell.titleLabel.text = inboxMessageMetadataJSON["title"]
                cell.subtitleLabel.text = inboxMessageMetadataJSON["subtitle"]
                
            } else {
                popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID)", controller: self)
            }
        } catch let error {
            popupSimpleNoteAlert(title: "Failed decode response data.", message: "mcID: \(inboxMessage.mcID) Error: \(error.localizedDescription)", controller: self)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width
        
        let cellHeight = cellWidth * 0.75 // 240 (height) / 320 (width) = 0.75
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
