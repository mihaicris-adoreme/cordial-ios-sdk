//
//  CartViewController.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class CartViewController: InAppMessageDelayViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var products = [Product]()
    
    let cartCell = "cartTableCell"
    let cartFooterIdentifier = "cartTableFooter"
    
    var cartTableFooterView: CartTableFooterView!
    
    let сordialAPI = CordialAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.title = "Cart"
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            products = AppDataManager.shared.cart.getCartItemsFromCoreData(appDelegate: appDelegate)
        }
        
        self.tableView.register(UINib(nibName: "CartTableFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: self.cartFooterIdentifier)
        self.cartTableFooterView = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: self.cartFooterIdentifier) as? CartTableFooterView
        self.cartTableFooterView.checkoutButton.addTarget(self, action: #selector(checkoutAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.upsertCartTableFooterView()
    }
    
    @objc func checkoutAction() {
        self.sendContactOrder()
        popupSimpleNoteAlert(title: "CHECKOUT", message: "SUCCESS", controller: self)
        
        self.deleteAllCartItems()
    }
    
    func sendContactOrder() {
        let shippingAddress = Address(name: "shippingAddressName", address: "shippingAddress", city: "shippingAddressCity", state: "shippingAddressState", postalCode: "shippingAddressPostalCode", country: "shippingAddressCountry")
        let billingAddress = Address(name: "billingAddressName", address: "billingAddress", city: "billingAddressCity", state: "billingAddressState", postalCode: "billingAddressPostalCode", country: "billingAddressCountry")
        let cartItems = self.getCartItems()
        
        let orderID = UUID().uuidString
        let order = Order(orderID: orderID, status: "orderStatus", storeID: "storeID", customerID: "customerID", shippingAddress: shippingAddress, billingAddress: billingAddress, items: cartItems, tax: nil, shippingAndHandling: nil, properties: nil)
        
        сordialAPI.sendContactOrder(order: order)
    }
    
    func deleteAllCartItems() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let entityName = AppDataManager.shared.cart.entityName
            AppDataManager.shared.deleteAllCoreDataByEntity(appDelegate: appDelegate, entityName: entityName)
            
            products.removeAll()
            self.upsertContactCart()
            self.upsertCartTableFooterView()
            
            tableView.reloadData()
        }
    }
    
    func upsertCartTableFooterView() {
        if !self.products.isEmpty {
            var totalQty: Int64 = 0
            var totalPrice: Double = 0
            self.products.forEach { product in
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let qty = AppDataManager.shared.cart.getCartItemQtyBySKU(appDelegate: appDelegate, sku: product.sku) {
                    totalQty += qty
                    totalPrice += product.price * Double(qty)
                }
            }
            if totalQty != 0 && totalPrice != 0 {
                self.cartTableFooterView.totalQtyLabel.text = String(totalQty)
                self.cartTableFooterView.totalPriceLabel.text = "$ \(String(totalPrice))"
            } else {
                self.tableView.tableFooterView = UIView(frame: .zero)
            }
        } else {
            self.tableView.tableFooterView = UIView(frame: .zero)
        }
        
        self.tableView.reloadData()
    }
    
    func upsertContactCart() {
        let cartItems = self.getCartItems()
        
        сordialAPI.upsertContactCart(cartItems: cartItems)
    }
    
    func getCartItems() -> [CartItem] {
        var cartItems = [CartItem]()
        
        products.forEach { product in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let qty = AppDataManager.shared.cart.getCartItemQtyBySKU(appDelegate: appDelegate, sku: product.sku) {
                
                let cartItem = CartItem(productID: product.id, name: product.name, sku: product.sku, category: "Mens", url: nil, itemDescription: nil, qty: qty, itemPrice: product.price, salePrice: product.price, attr: nil, images: [product.image], properties: nil)
                
                cartItems.append(cartItem)
            }
        }
        
        return cartItems
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white
        self.cartTableFooterView.backgroundView = backgroundView
        
        self.cartTableFooterView.checkoutButtonView.layer.shadowColor = UIColor.gray.cgColor
        self.cartTableFooterView.checkoutButtonView.layer.shadowOpacity = 1
        self.cartTableFooterView.checkoutButtonView.layer.shadowOffset = .zero
        self.cartTableFooterView.checkoutButtonView.layer.shadowRadius = 10
        
        return self.cartTableFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !products.isEmpty {
            let productHeight = self.tableView.frame.size.height / 3
            let productsHeight = productHeight * CGFloat(self.products.count)
            let calculatedHeightForFooter = self.tableView.frame.size.height - productsHeight
            
            if calculatedHeightForFooter > self.cartTableFooterView.frame.size.height {
                return calculatedHeightForFooter
            } else {
                return self.cartTableFooterView.frame.size.height
            }
        }
        
        return 0
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cartCell, for: indexPath) as! CartTableViewCell
        
        cell.nameLabel.text = products[indexPath.row].name
        cell.brandLabel.text = products[indexPath.row].brand
        cell.priceLabel.text = "$ \(products[indexPath.row].price)"
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let qty = AppDataManager.shared.cart.getCartItemQtyBySKU(appDelegate: appDelegate, sku: products[indexPath.row].sku) {
            cell.qtyLabel.text = String(qty)
        }
        
        if let image = UIImage(named: products[indexPath.row].img) {
            cell.productImageView.contentMode = .scaleAspectFit
            cell.productImageView.image = image
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 3
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete, let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            AppDataManager.shared.cart.deleteCartItemBySKU(appDelegate: appDelegate, sku: products[indexPath.row].sku)
            
            products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
            self.upsertContactCart()
            self.upsertCartTableFooterView()
        }
    }
}
