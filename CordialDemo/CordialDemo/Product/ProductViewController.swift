//
//  ProductViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProductViewController: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let cordialAPI = CordialAPI()
    
    var catalogName: String!
    var product: Product!
    
    let segueToCartIdentifier = "segueToCart"
    let segueAddToCartIdentifier = "segueAddToCart"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "cart"), style: .plain, target: self, action: #selector(cartButtonAction))
        
        self.title = product.name
        
        if let image = UIImage(named: product.img) {
            productImageView.contentMode = .scaleAspectFit
            productImageView.image = image
        }
        brandLabel.text = product.brand
        nameLabel.text = product.name
        priceLabel.text = "$ \(product.price)"
        descriptionLabel.text = product.shortDescription
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.sendCustomEvent(eventName: "browse_product", productName: product.name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cartViewController = segue.destination as? CartViewController, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch segue.identifier {
            case self.segueAddToCartIdentifier:
                AppDataManager.shared.setCartProductToCoreData(appDelegate: appDelegate, product: product)
                
                self.sendCustomEvent(eventName: "add_to_cart", productName: product.name)
                
                cartViewController.products = AppDataManager.shared.getCartItemsFromCoreData(appDelegate: appDelegate)
                cartViewController.upsertContactCart()
            default:
                break
            }
        }
    }
    
    @IBAction func addToCartAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: self.segueAddToCartIdentifier, sender: self)
    }
    
    func sendCustomEvent(eventName: String, productName: String) {
        let sendCustomEventRequest = SendCustomEventRequest(eventName: eventName, properties: ["productName": productName])
        self.cordialAPI.sendCustomEvent(sendCustomEventRequest: sendCustomEventRequest)
    }
    
    @objc func cartButtonAction() {
        self.performSegue(withIdentifier: self.segueToCartIdentifier, sender: self)
    }
}
