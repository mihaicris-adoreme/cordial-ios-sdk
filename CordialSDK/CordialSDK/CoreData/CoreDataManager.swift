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
    
    let coreDataSender = CoreDataSender()
    
    let frameworkIdentifier = "io.cordial.sdk"
    let frameworkName = "CordialSDK"
    let modelName = "CoreDataModel"
    
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    let contactLogoutRequest = ContactLogoutRequestCoreData()
    let inAppMessagesCache = InAppMessagesCacheCoreData()
    let inAppMessagesQueue = InAppMessagesQueueCoreData()
    let inAppMessagesParam = InAppMessagesParamCoreData()
    
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
            

            guard let resourceBundleURL = Bundle(for: type(of: self)).url(forResource: self.frameworkName, withExtension: "bundle") else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [resourceBundleURL is nil] frameworkName: [%{public}@]", log: OSLog.cordialError, type: .error, frameworkName)
                }
                return nil
            }
            
            guard let resourceBundle = Bundle(url: resourceBundleURL) else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [resourceBundle is nil] resourceBundleURL: [%{public}@] frameworkName: [%{public}@]", log: OSLog.cordialError, type: .error, resourceBundleURL.absoluteString, frameworkName)
                }
                return nil
            }
            
            return resourceBundle
        }
        
        guard let bundle = rawBundle else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Could not get bundle that contains the model", log: OSLog.cordialError, type: .error)
            }
            
            return NSManagedObjectModel()
        }
        
        guard
            let modelURL = bundle.url(forResource: self.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("Could not get bundle for managed object model", log: OSLog.cordialError, type: .error)
                }
                
                return NSManagedObjectModel()
        }
        
        return model
    }()
    
    func deleteAllCoreDataByEntity(entityName: String) {
        let context = self.persistentContainer.viewContext
        
        context.mergePolicy = NSMergePolicyType.overwriteMergePolicyType
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Delete CoreData by entity failed with error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
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
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesParam.entityName)
    }
    
}
