//
//  InboxMessagesContentCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 02.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessagesContentCoreData {
    
    let entityName = "InboxMessagesContent"
    
    // MARK: Setting Data
    
    func putInboxMessageContent(mcID: String, content: String) {
        
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCacheSize > contentSize {
            
            guard let inboxMessagesContentSize = self.fetchInboxMessagesContentSize() else { return }
            
            if InboxMessageCache.shared.maxCacheSize > inboxMessagesContentSize {
                self.saveInboxMessageContent(mcID: mcID, content: content)
            } else {
                self.removeLatestInboxMessageContent()
                
                LoggerManager.shared.info(message: "Exceeded max cache size. Removing the firstest cached inbox message content to free storage capacity.", category: "CordialSDKInboxMessages")
                
                self.putInboxMessageContent(mcID: mcID, content: content)
            }
        } else {
            LoggerManager.shared.info(message: "Message didn't enter the cache. Message size exceeded max cache size.", category: "CordialSDKInboxMessages")
        }
    }
    
    private func saveInboxMessageContent(mcID: String, content: String) {
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCachableMessageSize > contentSize {
            
            self.setInboxMessageContent(mcID: mcID, content: content)
        } else {
            LoggerManager.shared.info(message: "Message didn't enter the cache. Message size exceeded max cacheable message size.", category: "CordialSDKInboxMessages")
        }
    }
    
    private func setInboxMessageContent(mcID: String, content: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            managedObject.setValue(mcID, forKey: "mcID")
            managedObject.setValue(content, forKey: "content")
            managedObject.setValue(content.data(using: .utf8)?.count, forKey: "size")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessageContent(mcID: String) -> String? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                if let content = managedObject.value(forKey: "content") as? String {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    return content
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    private func fetchInboxMessagesContentSize() -> Int? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var storageSize = 0
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                if let size = managedObject.value(forKey: "size") as? Int {
                    storageSize += size
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return storageSize
    }
    
    // MARK: Removing Data
    
    func removeInboxMessageContent(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func removeLatestInboxMessageContent() {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.fetchLimit = 1
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
}
