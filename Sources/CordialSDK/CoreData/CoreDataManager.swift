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
            let container = NSPersistentContainer(name: self.modelName, managedObjectModel: managedObjectModel)
            
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
        guard let resourceBundle = InternalCordialAPI().getResourceBundle() else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle that contains the model]", log: OSLog.cordialCoreDataError, type: .error)
            }
            
            return nil
        }
        
        guard let modelURL = resourceBundle.url(forResource: self.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle for managed object model]", log: OSLog.cordialCoreDataError, type: .error)
            }
            
            return nil
        }
        
        return model
    }
    
    func deleteManagedObjectByContext(managedObject: NSManagedObject, context: NSManagedObjectContext) {
        ThreadQueues.shared.queueInAppMessage.sync(flags: .barrier) {
            do {
                context.delete(managedObject)
                try context.save()
            
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription)
                }
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
        ThreadQueues.shared.queueContactTimestamps.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactTimestampsURL.entityName)
        }
        
        ThreadQueues.shared.queueSendCustomEvent.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.customEventRequests.entityName)
        }
        
        ThreadQueues.shared.queueUpsertContactCart.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactCartRequest.entityName)
        }
        
        ThreadQueues.shared.queueSendContactOrder.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactOrderRequests.entityName)
        }
            
        ThreadQueues.shared.queueUpsertContact.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactRequests.entityName)
        }
                    
        ThreadQueues.shared.queueInAppMessage.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessageContentURL.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesCache.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesQueue.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesParam.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesRelated.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesShown.entityName)
        }
        
        ThreadQueues.shared.queueSendContactLogout.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactLogoutRequest.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessagesMarkReadUnread.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesMarkReadUnread.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessageDelete.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessageDelete.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessagesCache.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesCache.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessagesContent.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesContent.entityName)
        }
        
    }
    
}
