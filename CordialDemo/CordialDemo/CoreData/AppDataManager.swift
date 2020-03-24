//
//  AppDataManager.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 4/16/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class AppDataManager {
    
    public static let shared = AppDataManager()
    
    let cart = CartCoreData()
    let attributes = AttributesCoreData()
    let geoAttributes = AttributesGeoCoreData()
    
    private init(){}
    
    func deleteAllCoreDataByEntity(appDelegate: AppDelegate, entityName: String) {
        let context = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
}
