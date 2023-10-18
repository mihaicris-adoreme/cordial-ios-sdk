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
                    LoggerManager.shared.error(message: "CoreData `loadPersistentStores` Error: [\(error.localizedDescription)] Info: \(error.userInfo)", category: "CordialSDKCoreDataError")
                 }
            })
            
            return container
        }

        return nil
    }()
    
    private func getManagedObjectModel() -> NSManagedObjectModel? {
        guard let resourceBundleURL = InternalCordialAPI().getResourceBundleURL(forResource: self.modelName, withExtension: "momd") else { return nil }
        
        guard let model = NSManagedObjectModel(contentsOf: resourceBundleURL) else {
            LoggerManager.shared.error(message: "CoreData `getManagedObjectModel` Error: [Could not get bundle for managed object model]", category: "CordialSDKCoreDataError")
            
            return nil
        }
        
        return model
    }
    
    func updateSendingRequestsIfNeeded() {
        if InternalCordialAPI().isUserLogin() {
            DispatchQueue.main.async {
                self.updateSendingRequests(entityName: self.customEventRequests.entityName)
                self.updateSendingRequests(entityName: self.contactRequests.entityName)
                self.updateSendingRequests(entityName: self.contactCartRequest.entityName)
                self.updateSendingRequests(entityName: self.contactOrderRequests.entityName)
                self.updateSendingRequests(entityName: self.contactLogoutRequest.entityName)
                self.updateSendingRequests(entityName: self.inboxMessagesMarkReadUnread.entityName)
                self.updateSendingRequests(entityName: self.inboxMessageDelete.entityName)
            }
        }
    }
    
    private func updateSendingRequests(entityName: String) {
        guard let context = self.persistentContainer?.viewContext else { return }

        let request = NSBatchUpdateRequest(entityName: entityName)
        request.resultType = .statusOnlyResultType
        
        request.predicate = NSPredicate(format: "flushing = %@", NSNumber(value: true))
        request.propertiesToUpdate = ["flushing": NSNumber(value: false)]
        
        do {
            try context.execute(request)
        } catch let error {
            self.deleteAll(context: context, entityName: entityName)
            
            LoggerManager.shared.error(message: "CoreData `updateSendingRequests` Error: [\(error.localizedDescription)] Entity: [\(entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func isObjectExist(requestID: String, entityName: String) -> Bool? {
        guard let context = self.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "requestID = %@", requestID)
        request.predicate = predicate
        
        return self.isObjectExist(context: context, request: request, entityName: entityName)
    }
    
    func isObjectExist(mcID: String, entityName: String) -> Bool? {
        guard let context = self.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        return self.isObjectExist(context: context, request: request, entityName: entityName)
    }
    
    private func isObjectExist(context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>, entityName: String) -> Bool {
        do {
            if let managedObjects = try context.fetch(request) as? [NSManagedObject],
               managedObjects.count > 0 {
                
                return true
            }
        } catch let error {
            self.deleteAll(context: context, entityName: entityName)
            
            LoggerManager.shared.error(message: "CoreData `isObjectExist` Error: [\(error.localizedDescription)] Entity: [\(entityName)]", category: "CordialSDKCoreDataError")
        }

        return false
    }
    
    func removeObject(requestID: String, entityName: String) {
        guard let context = self.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", requestID)
        
        self.removeObject(context: context, request: request, entityName: entityName)
    }
    
    func removeObject(mcID: String, entityName: String) {
        guard let context = self.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        self.removeObject(context: context, request: request, entityName: entityName)
    }
    
    private func removeObject(context: NSManagedObjectContext, request: NSFetchRequest<NSFetchRequestResult>, entityName: String) {
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.removeManagedObject(managedObject: managedObject, context: context, entityName: entityName)
            }
        } catch let error {
            self.deleteAll(context: context, entityName: entityName)
            
            LoggerManager.shared.error(message: "CoreData `removeObject` Error: [\(error.localizedDescription)] Entity: [\(entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func saveContext(context: NSManagedObjectContext, entityName: String) {
        do {
            try context.save()
        } catch let error {
            self.deleteAll(context: context, entityName: entityName)
            
            LoggerManager.shared.error(message: "CoreData `saveContext` Error: [\(error.localizedDescription)] Entity: [\(entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func removeManagedObject(managedObject: NSManagedObject, context: NSManagedObjectContext, entityName: String) {
        do {
            context.delete(managedObject)
            try context.save()
        } catch let error {
            self.deleteAll(context: context, entityName: entityName)
            
            LoggerManager.shared.error(message: "CoreData `removeManagedObject` Error: [\(error.localizedDescription)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func deleteAll(context: NSManagedObjectContext, entityName: String) {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch let error {
            LoggerManager.shared.error(message: "CoreData `deleteAll` Error: [\(error.localizedDescription)] Entity: [\(entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func deleteAllCoreData() {
        guard let context = self.persistentContainer?.viewContext,
              let managedObjectModel = self.getManagedObjectModel() else { return }
        
        let entityNames = managedObjectModel.entitiesByName.map { $0.key }
        
        entityNames.forEach { entityNames in
            self.deleteAll(context: context, entityName: entityNames)
        }
    }
}
