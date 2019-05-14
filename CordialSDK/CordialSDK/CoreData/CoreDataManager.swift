//
//  CoreDataManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    public static let shared = CoreDataManager()
    
    private init(){}
    
    let modelName = "CoreDataModel"
    
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    
    lazy var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: self.managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        
        var rawBundle: Bundle? {
            
            let bundle = Bundle(for: type(of: self))
            let dictionary = bundle.infoDictionary!
            
            let frameworkIdentifier = dictionary["CFBundleIdentifier"] as! String
            
            if let bundle = Bundle(identifier: frameworkIdentifier) {
                return bundle
            }
            
            let frameworkName = dictionary["CFBundleName"] as! String
            
            guard
                let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: frameworkName, withExtension: "bundle"),
                let resourceBundle = Bundle(url: resourceBundleURL) else {
                    return nil
                }
            
            return resourceBundle
        }
        
        guard let bundle = rawBundle else {
            print("Could not get bundle that contains the model ")
            return NSManagedObjectModel()
        }
        
        guard
            let modelURL = bundle.url(forResource: self.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                print("Could not get bundle for managed object model")
                return NSManagedObjectModel()
        }
        
        return model
    }()
    
    func deleteAllCoreDataByEntity(entityName: String) {
        let context = persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func deleteAllCoreData() {
        self.deleteAllCoreDataByEntity(entityName: customEventRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactCartRequest.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactOrderRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactRequests.entityName)
    }
    
}
