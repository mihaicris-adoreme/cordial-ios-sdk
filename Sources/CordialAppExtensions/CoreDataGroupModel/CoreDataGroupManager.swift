//
//  CoreDataGroupManager.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 15.10.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CoreDataGroupManager {
    
    static let shared = CoreDataGroupManager()

    private init() {}

    let modelName = "CoreDataGroupModel"

    // MARK: Core Data Stack
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    private lazy var managedObjectModel: NSManagedObjectModel? = {
        guard let resourceBundleURL = self.getResourceBundleURL(forResource: self.modelName, withExtension: "momd") else { return nil }
        
        guard let model = NSManagedObjectModel(contentsOf: resourceBundleURL) else {
            os_log("CordialSDK_AppExtensions CoreData Error: [Could not get bundle for managed object model]", log: .default, type: .error)
            
            return nil
        }
        
        return model
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else { return nil }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let storeName = "\(self.modelName).sqlite"

        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)
        
        let persistentStoreURL = storeURL?.appendingPathComponent(storeName)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: nil)
        } catch let error {
            os_log("CordialSDK_AppExtensions CoreData Error: [Unable to load persistent store coordinator.], Info: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            return nil
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: SDK resource bundle
    
    private func getResourceBundleURL(forResource: String, withExtension: String) -> URL? {
        guard let resourceBundle = Bundle.resourceBundle else {
            os_log("CordialSDK_AppExtensions Error: [Could not get bundle that contains the model]", log: .default, type: .error)
            
            return nil
        }
        
        guard let resourceBundleURL = resourceBundle.url(forResource: forResource, withExtension: withExtension) else {
            os_log("CordialSDK_AppExtensions Error: [Could not get bundle url for file %{public}@.%{public}@", log: .default, type: .error, forResource, withExtension)
            
            return nil
        }
        
        return resourceBundleURL
    }
    
}
