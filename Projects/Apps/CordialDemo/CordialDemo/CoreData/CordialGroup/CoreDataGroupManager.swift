//
//  CoreDataGroupManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CoreDataGroupManager {
    
    static let shared = CoreDataGroupManager()

    private init() {}

    let modelName = "CoreDataGroupModel"

    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let resourceBundleURL = self.getResourceBundleURL(forResource: self.modelName, withExtension: "momd") else { return nil }
        
        guard let model = NSManagedObjectModel(contentsOf: resourceBundleURL) else {
            os_log("CoreData Error: [Could not get bundle for managed object model]", log: .сordialSDKDemo, type: .error)
            
            return nil
        }
        
        return model
    }()
    
    // Get resource bundle URL
    
    private func getResourceBundleURL(forResource: String, withExtension: String) -> URL? {
        guard let resourceBundle = self.getResourceBundle() else {
            os_log("CoreData Error: [Could not get bundle that contains the model]", log: .сordialSDKDemo, type: .error)
            
            return nil
        }
        
        guard let resourceBundleURL = resourceBundle.url(forResource: forResource, withExtension: withExtension) else {
            os_log("CoreData Error: [Could not get bundle url for file %{public}@.%{public}@]", log: .сordialSDKDemo, type: .error, forResource, withExtension)
            
            return nil
        }
        
        return resourceBundleURL
    }
    
    // Get resource bundle
    
    private func getResourceBundle() -> Bundle? {
        guard let identifier = Bundle.main.bundleIdentifier,
              let resourceBundle = Bundle(identifier: identifier) else {
            
            os_log("CoreData Error: ResourceBundle Unexpected Error", log: .сordialSDKDemo, type: .error)
            
            return nil
        }
        
        return resourceBundle
    }
    
    // Get persistent ctore coordinator

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else { return nil }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let storeName = "\(self.modelName).sqlite"
        
        if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.cordial.sdk") {
            
            let persistentStoreURL = storeURL.appendingPathComponent(storeName)
            
            do {
                if #available(iOS 15.0, *) {
                    let persistentStore = try persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
                    try persistentStore.loadMetadata()
                } else {
                    let persistentStore = try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
                    try persistentStore.loadMetadata()
                }
            } catch let error {
                os_log("CoreData Error: [Unable to load CoreData persistent store] Info: %{public}@", log: .сordialSDKDemo, type: .error, error.localizedDescription)
                
                return nil
            }
        } else {
            os_log("CoreData Error: [Unable to prepare CoreData store App Group URL]", log: .сordialSDKDemo, type: .error)
            
            return nil
        }
        
        return persistentStoreCoordinator
    }()
}
