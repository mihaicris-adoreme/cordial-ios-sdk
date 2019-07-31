//
//  CoreDataManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CoreDataManager {

    static let shared = CoreDataManager()
    
    private init(){}
    
    let frameworkIdentifier = "io.cordial.sdk"
    let modelName = "CoreDataModel"
    
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    let contactLogoutRequest = ContactLogoutRequestCoreData()
    let inAppMessagesCache = InAppMessagesCacheCoreData()
    let inAppMessagesQueue = InAppMessagesQueueCoreData()
    
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
            
            if let bundle = Bundle(identifier: self.frameworkIdentifier) {
                return bundle
            }
            
            let dictionary = Bundle(for: type(of: self)).infoDictionary!
            let frameworkName = dictionary["CFBundleName"] as! String
            
            guard
                let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: frameworkName, withExtension: "bundle"),
                let resourceBundle = Bundle(url: resourceBundleURL) else {
                    return nil
                }
            
            return resourceBundle
        }
        
        guard let bundle = rawBundle else {
            os_log("Could not get bundle that contains the model", log: OSLog.cordialError, type: .error)
            return NSManagedObjectModel()
        }
        
        guard
            let modelURL = bundle.url(forResource: self.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                os_log("Could not get bundle for managed object model", log: OSLog.cordialError, type: .error)
                return NSManagedObjectModel()
        }
        
        return model
    }()
    
    func deleteAllCoreDataByEntity(entityName: String) {
        let context = self.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            os_log("Delete CoreData by entity failed with error", log: OSLog.cordialError, type: .error)
        }
    }
    
    func deleteAllCoreData() {
        self.deleteAllCoreDataByEntity(entityName: self.customEventRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.contactCartRequest.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.contactOrderRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.contactRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.contactLogoutRequest.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesCache.entityName)
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesQueue.entityName)
    }
    
}
