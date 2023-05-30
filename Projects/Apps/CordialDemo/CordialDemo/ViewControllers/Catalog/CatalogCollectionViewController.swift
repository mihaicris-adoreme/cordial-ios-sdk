//
//  CatalogCollectionViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CatalogCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let cordialAPI = CordialAPI()
    
    let reuseIdentifier = "catalogCollectionCell"
    let segueToProductIdentifier = "segueToProduct"
    let segueToCartIdentifier = "segueToCart"
    let segueToProfileIdentifier = "segueToProfile"
    let segueToCustomEventIdentifier = "segueToCustomEvent"
    let segueToInboxTableIdentifier = "segueToInboxTable"
    let segueToInboxTableListIdentifier = "segueToInboxTableList"
    let segueToInboxCollectionIdentifier = "segueToInboxCollection"
    let segueToPushNotificationSettings = "segueToPushNotificationSettings"
    let sequeToLogsIdentifier = "segueToLogs"
    
    let catalogName = "Mens"
    
    let products = ProductHandler.shared.products
    
    var selectedItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.catalogName
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let cartButton = UIBarButtonItem(image: UIImage(named: "cart"), style: .plain, target: self, action: #selector(cartButtonAction))
        navigationItem.rightBarButtonItems = [cartButton]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sendBrowseCategoryCustomEvent()
    }
    
    func sendBrowseCategoryCustomEvent() {
        let eventName = "browse_category"
        self.cordialAPI.sendCustomEvent(eventName: eventName, properties: ["catalogName": self.catalogName])
    }
    
    @objc func cartButtonAction() {
        self.performSegue(withIdentifier: self.segueToCartIdentifier, sender: self)
    }
    
    @IBAction func menuButtonAction(_ sender: UIBarButtonItem) {
        let menuTableViewController = MenuTableViewController()
        menuTableViewController.sender = self
        
        self.present(menuTableViewController, animated: true)
    }
    
    func loginAction() {
        App.userLogOut()
        
        self.presentLoginNavigationController(.formSheet)
    }
    
    func logoutAction() {
        self.cordialAPI.unsetContact()
        
        App.userLogOut()
        
        self.presentLoginNavigationController(.fullScreen)
    }
    
    func presentLoginNavigationController(_ modalPresentationStyle: UIModalPresentationStyle) {
        let loginNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationController")
        loginNavigationController.modalPresentationStyle = modalPresentationStyle
        
        self.present(loginNavigationController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToProductIdentifier:
            if let productViewController = segue.destination as? ProductViewController {
                productViewController.catalogName = self.catalogName
                
                if let cell = sender as? CatalogCollectionViewCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                    productViewController.product = self.products[selectedIndexPath.row] as Product
                }
            }
        default:
            break
        }
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! CatalogCollectionViewCell
        
        cell.nameLabel.text = self.products[indexPath.row].name
        cell.brandLabel.text = self.products[indexPath.row].brand
        cell.priceLabel.text = "$ \(self.products[indexPath.row].price)"
        
        if let image = UIImage(named: self.products[indexPath.row].img) {
            cell.catalogImageView.contentMode = .scaleAspectFit
            cell.catalogImageView.image = image
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width / 2 - 10 // margins
        
        let cellHeight = cellWidth * 1.6 // 240 (height) / 150 (width) = 1.6
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
