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
    
    let modelName = "CoreDataModel"
    
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    let contactLogoutRequest = ContactLogoutRequestCoreData()
    let inAppMessagesCache = InAppMessagesCacheCoreData()
    let inAppMessagesQueue = InAppMessagesQueueCoreData()
    let inAppMessagesParam = InAppMessagesParamCoreData()
    let inAppMessagesShown = InAppMessagesShownCoreData()
    let inboxMessagesMarkReadUnread = InboxMessagesMarkReadUnreadCoreData()
    let inboxMessageDelete = InboxMessageDeleteCoreData()
    
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
        
        guard let resourceBundle = InternalCordialAPI().getResourceBundle() else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle that contains the model]", log: OSLog.cordialError, type: .error)
            }
            
            return NSManagedObjectModel()
        }
        
        guard let modelURL = resourceBundle.url(forResource: self.modelName, withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL) else {
                
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [Could not get bundle for managed object model]", log: OSLog.cordialError, type: .error)
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
        ThreadQueues.shared.queueSendCustomEventRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.customEventRequests.entityName)
        }
        
        ThreadQueues.shared.queueUpsertContactCartRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactCartRequest.entityName)
        }
        
        ThreadQueues.shared.queueSendContactOrderRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactOrderRequests.entityName)
        }
            
        ThreadQueues.shared.queueUpsertContactRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactRequests.entityName)
        }
            
        ThreadQueues.shared.queueFetchInAppMessages.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesCache.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesQueue.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesParam.entityName)
            self.deleteAllCoreDataByEntity(entityName: self.inAppMessagesShown.entityName)
        }
        
        ThreadQueues.shared.queueSendContactLogoutRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.contactLogoutRequest.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessagesMarkReadUnreadRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessagesMarkReadUnread.entityName)
        }
        
        ThreadQueues.shared.queueInboxMessageDeleteRequest.sync(flags: .barrier) {
            self.deleteAllCoreDataByEntity(entityName: self.inboxMessageDelete.entityName)
        }
    }
    
}
