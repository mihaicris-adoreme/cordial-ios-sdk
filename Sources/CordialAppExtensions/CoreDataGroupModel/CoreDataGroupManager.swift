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
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator

        return managedObjectContext
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        let managedObjectModel = NSManagedObjectModel()
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let storeName = "\(self.modelName).sqlite"

        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)
        
        let persistentStoreURL = storeURL?.appendingPathComponent(storeName)

        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: [
                                                                NSMigratePersistentStoresAutomaticallyOption: true,
                                                                NSInferMappingModelAutomaticallyOption: true
                                                              ])
        } catch let error {
            os_log("CordialSDK_AppExtensions: Error [Unable to load CoreData persistent store coordinator] Info: %{public}@", log: .default, type: .error, error.localizedDescription)
            
            return nil
        }
        
        return persistentStoreCoordinator
    }()
    
}
