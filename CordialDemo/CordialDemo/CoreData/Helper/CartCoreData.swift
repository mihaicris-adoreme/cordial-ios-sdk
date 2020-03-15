//
//  CartCoreData.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 15.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class CartCoreData {
    
    let entityName = "Cart"
    
    func setCartProductToCoreData(appDelegate: AppDelegate, product: Product) {
        let context = appDelegate.persistentContainer.viewContext
        
        if !self.isProductInCart(appDelegate: appDelegate, sku: product.sku) {
            // Add one new product to cart cache
            if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    if #available(iOS 11.0, *) {
                        let productData = try NSKeyedArchiver.archivedData(withRootObject: product, requiringSecureCoding: false)
                        
                        newRow.setValue(productData, forKey: "product")
                        newRow.setValue(product.sku, forKey: "sku")
                        newRow.setValue(1, forKey: "qty")
                    } else {
                        let productData = NSKeyedArchiver.archivedData(withRootObject: product)
                        
                        newRow.setValue(productData, forKey: "product")
                        newRow.setValue(product.sku, forKey: "sku")
                        newRow.setValue(1, forKey: "qty")
                    }
                    
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        } else {
            // Increase cart product cache qty by one
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
            request.predicate = NSPredicate(format: "sku == %@", product.sku)
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try context.fetch(request)
                if result.count == 1 {
                    let productData = result.first as! NSManagedObject
                    var qty = productData.value(forKey: "qty") as! Int64
                    qty += 1
                    productData.setValue(qty, forKey: "qty")
                    
                    try context.save()
                }
            } catch let error as NSError {
                print("Failed: \(error) \(error.userInfo)")
            }
        }
    }
    
    func getCartItemsFromCoreData(appDelegate: AppDelegate) -> [Product] {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var products = [Product]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let anyData = data.value(forKey: "product") else { continue }
                let data = anyData as! Data
                
                if let product = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Product {
                    products.append(product)
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return products
    }
    
    func deleteCartItemBySKU(appDelegate: AppDelegate, sku: String) {
        let context = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        deleteFetch.predicate = NSPredicate(format: "sku == %@", sku)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func getCartItemQtyBySKU(appDelegate: AppDelegate, sku: String) -> Int64? {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "sku == %@", sku)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let productData = result.first as! NSManagedObject
                let qty = productData.value(forKey: "qty") as! Int64
                
                return qty
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return nil
    }
    
    func isProductInCart(appDelegate: AppDelegate, sku: String) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "sku == %@", sku)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let productData = result.first as! NSManagedObject
                let productSKU = productData.value(forKey: "sku") as! String
                if productSKU == sku {
                    return true
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return false
    }
    
}
