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
    
    let cordialAPI = CordialAPI()
    
    let reuseIdentifier = "catalogCell"
    let segueToProductIdentifier = "segueToProduct"
    let segueToCartIdentifier = "segueToCart"
    let segueToProfileIdentifier = "segueToProfile"
    
    @IBOutlet weak var profileButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let catalogName = "Mens"
    
    let products = ProductHandler.shared.products
    
    var selectedItem: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cart"), style: .plain, target: self, action: #selector(cartButtonAction))
        
        self.title = catalogName
        
        self.prerareProfileAndLogoutButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sendBrowseCategoryCustomEvent()
    }
    
    func prerareProfileAndLogoutButtons() {
        if App.isGuestUser() {
            self.profileButtonItem.isEnabled = false
        }
    }
    
    func sendBrowseCategoryCustomEvent() {
        let eventName = "browse_category"
        self.cordialAPI.sendCustomEvent(eventName: eventName, properties: ["catalogName": catalogName])
    }
    
    @objc func cartButtonAction() {
        self.performSegue(withIdentifier: self.segueToCartIdentifier, sender: self)
    }
    
    @IBAction func profileButtonAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToProfileIdentifier, sender: self)
    }
    
    @IBAction func logoutButtonAction(_ sender: UIBarButtonItem) {
        self.cordialAPI.unsetContact()
        
        App.userLogOut()
        
        let loginNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginNavigationController")
        loginNavigationController.modalPresentationStyle = .fullScreen
        
        self.present(loginNavigationController, animated: true, completion: nil)
    }
    
    // MARK: Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case self.segueToProductIdentifier:
            if let productViewController = segue.destination as? ProductViewController {
                productViewController.catalogName = catalogName
                
                if let cell = sender as? CatalogCollectionViewCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                    productViewController.product = products[selectedIndexPath.row] as Product
                }
            }
        default:
            break
        }
        
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatalogCollectionViewCell
        
        cell.nameLabel.text = products[indexPath.row].name
        cell.brandLabel.text = products[indexPath.row].brand
        cell.priceLabel.text = "$ \(products[indexPath.row].price)" 
        
        if let image = UIImage(named: products[indexPath.row].img) {
            cell.catalogImageView.contentMode = .scaleAspectFit
            cell.catalogImageView.image = image
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = screenSize.width / 2 - 10 // margins
        
        let cellHeight = cellWidth * 1.6 // 240 (height) / 150 (width) = 1.6
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
