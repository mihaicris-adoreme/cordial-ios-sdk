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
    
    private init() {}
    
    let coreDataSender = CoreDataSender()
    
    let modelName = "CoreDataModel"
    
    let contactTimestampsURL = ContactTimestampsURLCoreData()
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    let contactLogoutRequest = ContactLogoutRequestCoreData()
    let inAppMessageContentURL = InAppMessageContentURLCoreData()
    let inAppMessagesCache = InAppMessagesCacheCoreData()
    let inAppMessagesQueue = InAppMessagesQueueCoreData()
    let inAppMessagesParam = InAppMessagesParamCoreData()
    let inAppMessagesRelated = InAppMessagesRelatedCoreData()
    let inAppMessagesShown = InAppMessagesShownCoreData()
    let inboxMessagesMarkReadUnread = InboxMessagesMarkReadUnreadCoreData()
    let inboxMessageDelete = InboxMessageDeleteCoreData()
    let inboxMessagesCache = InboxMessagesCacheCoreData()
    let inboxMessagesContent = InboxMessagesContentCoreData()
    
    lazy var persistentContainer: NSPersistentContainer? = {
    
        if let managedObjectModel = self.getManagedObjectModel() {
            let container = CoreDataContainer(name: self.modelName, managedObjectModel: managedObjectModel)
            
            let description = NSPersistentStoreDescription()

            description.shouldInferMappingModelAutomatically = true
            description.shouldMigrateStoreAutomatically = true

            container.persistentStoreDescriptions.append(description)
            
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("CoreData Unresolved Error: [%{public}@], Info: %{public}@", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, error.userInfo)
                    }
                 }
            })
            
            return container
        }

        return nil
    }()
    
    private func getManagedObjectModel() -> NSManagedObjectModel? {
        guard let resourceBundleURL = InternalCordialAPI().getResourceBundleURL(forResource: self.modelName, withExtension: "momd") else { return nil }
        
        guard let model = NSManagedObjectModel(contentsOf: resourceBundleURL) else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle for managed object model]", log: OSLog.cordialCoreDataError, type: .error)
            }
            
            return nil
        }
        
        return model
    }
    
    func deleteManagedObjectByContext(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        do {
            context.delete(managedObject)
            try context.save()
        
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription)
            }
        }
    }
    
    func deleteAllCoreDataByEntity(entityName: String) {
        guard let context = self.persistentContainer?.viewContext else { return }
        
        context.mergePolicy = NSMergePolicyType.overwriteMergePolicyType
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("Delete CoreData Entity Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, entityName)
            }
        }
    }
    
    func deleteAllCoreData() {
        self.deleteAllCoreDataByEntity(entityName: self.contactTimestampsURL.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.customEventRequests.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.contactCartRequest.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.contactOrderRequests.entityName)
            
        self.deleteAllCoreDataByEntity(entityName: self.contactRequests.entityName)
                    
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessageContentURL.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesCache.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesQueue.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesParam.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesRelated.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesShown.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.contactLogoutRequest.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesMarkReadUnread.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inboxMessageDelete.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesCache.entityName)
        
        self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesContent.entityName)
        
    }
    
}
