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
    @IBOutlet weak var logoutButtonItem: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let catalogName = "Mens"
    
    let products = [
        Product(id: "1", img: "men1", brand: "Robert Graham", name: "Alix Long Sleeve Woven Shirt", price: 148.00, sku: "ab26ec3a-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size"),
        Product(id: "2", img: "men2", brand: "Robert Graham", name: "Back Off Polo", price: 98.00, sku: "ab26efdc-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size"),
        Product(id: "3", img: "men3", brand: "Robert Graham", name: "Back Off Polo", price: 98.00, sku: "ab26f446-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size"),
        Product(id: "4", img: "men4", brand: "Robert Graham", name: "Baylor Long Sleeve Woven Shirt", price: 148.00, sku: "ab26f5b8-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size"),
        Product(id: "5", img: "men5", brand: "DSQUARED2", name: "Black Watch Woven Shirt", price: 685.00, sku: "ab26f75c-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size"),
        Product(id: "6", img: "men6", brand: "Rip Curl", name: "Botanical Short Sleeve Shirt", price: 54.50, sku: "ab26f89c-6110-11e9-8647-d663bd873d93", shortDescription: "\u{00B7} Classic styling \n\u{00B7} Clean lines \n\u{00B7} Brand mark logo on center \n\u{00B7} 50% 50% mix \n\u{00B7} Washable \n\u{00B7} Imported \n\u{00B7} Measurements: Length: 10 \n\u{00B7} Product measurements were taken using size MD \n\u{00B7} Please note that measurements may vary by size")
    ]
    
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
        if cordialAPI.getContactPrimaryKey() == nil {
            self.profileButtonItem.isEnabled = false
            self.logoutButtonItem.title = "Login"
            
        }
    }
    
    func sendBrowseCategoryCustomEvent() {
        let eventName = "browse_category"
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: ["catalogName": catalogName])
        cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func cartButtonAction() {
        self.performSegue(withIdentifier: self.segueToCartIdentifier, sender: self)
    }
    
    @IBAction func profileButtonAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: self.segueToProfileIdentifier, sender: self)
    }
    
    @IBAction func logoutButtonAction(_ sender: UIBarButtonItem) {
        if cordialAPI.getContactPrimaryKey() != nil {
            cordialAPI.unsetContact()
        }
        
        self.dismiss(animated: true, completion: nil)
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
