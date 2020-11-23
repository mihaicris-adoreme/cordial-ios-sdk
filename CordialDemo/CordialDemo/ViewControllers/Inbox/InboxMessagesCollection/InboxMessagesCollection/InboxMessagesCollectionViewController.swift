//
//  InboxMessagesCollectionViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 23.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class InboxMessagesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "inboxMessagesCollectionCell"
    
    var inboxMessages = [InboxMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Inbox"
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
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
        
        cell.titleLabel.text = self.inboxMessages[indexPath.row].mcID
        
        return cell
    }
}
