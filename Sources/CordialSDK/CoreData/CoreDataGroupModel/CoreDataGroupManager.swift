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
        guard let resourceBundleURL = InternalCordialAPI().getResourceBundleURL(forResource: self.modelName, withExtension: "momd") else { return nil }
        
        guard let model = NSManagedObjectModel(contentsOf: resourceBundleURL) else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle for managed object model]", log: OSLog.cordialCoreDataError, type: .error)
            }
            
            return nil
        }
        
        return model
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let managedObjectModel = self.managedObjectModel else { return nil }
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let storeName = "\(self.modelName).sqlite"

        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)
        
        if let persistentStoreURL = storeURL?.appendingPathComponent(storeName) {
            do {
                if #available(iOS 15.0, *) {
                    let persistentStore = try persistentStoreCoordinator.addPersistentStore(type: .sqlite, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
                    try persistentStore.loadMetadata()
                } else {
                    let persistentStore = try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
                    try persistentStore.loadMetadata()
                }
            } catch let error {
                os_log("CoreData Error: [Unable to load CoreData persistent store] Info: %{public}@", log: .cordialCoreDataError, type: .error, error.localizedDescription)
                
                return nil
            }
        } else {
            os_log("CoreData Error: [Unable to prepare CoreData persistent store App Group URL]", log: .cordialCoreDataError, type: .error)
            
            return nil
        }
        
        return persistentStoreCoordinator
    }()
}
