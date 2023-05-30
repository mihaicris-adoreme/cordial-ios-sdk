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
    
    func putInboxMessageContentToCoreData(mcID: String, content: String) {
        
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCacheSize > contentSize {
            
            guard let inboxMessagesContentSize = self.getInboxMessagesContentSizeAtCoreData() else { return }
            
            if InboxMessageCache.shared.maxCacheSize > inboxMessagesContentSize {
                self.saveInboxMessageContentToCoreData(mcID: mcID, content: content)
            } else {
                self.removeLastInboxMessageContentFromCoreData()
                
                LoggerManager.shared.info(message: "Exceeded max cache size. Removing the firstest cached inbox message content to free storage capacity.", category: "CordialSDKInboxMessages")
                
                self.putInboxMessageContentToCoreData(mcID: mcID, content: content)
            }
        } else {
            LoggerManager.shared.info(message: "Message didn't enter the cache. Message size exceeded max cache size.", category: "CordialSDKInboxMessages")
        }
    }
    
    func getInboxMessageContentFromCoreData(mcID: String) -> String? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                if let content = managedObject.value(forKey: "content") as? String {
                    return content
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func removeInboxMessageContentFromCoreData(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func removeLastInboxMessageContentFromCoreData() {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func saveInboxMessageContentToCoreData(mcID: String, content: String) {
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCachableMessageSize > contentSize {
            
            self.setInboxMessageContentToCoreData(mcID: mcID, content: content)
        } else {
            LoggerManager.shared.info(message: "Message didn't enter the cache. Message size exceeded max cacheable message size.", category: "CordialSDKInboxMessages")
        }
    }
    
    private func setInboxMessageContentToCoreData(mcID: String, content: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newObject.setValue(mcID, forKey: "mcID")
                newObject.setValue(content, forKey: "content")
                newObject.setValue(content.data(using: .utf8)?.count, forKey: "size")
                
                try context.save()
            } catch let error {
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    private func getInboxMessagesContentSizeAtCoreData() -> Int? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var storageSize = 0
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                if let size = managedObject.value(forKey: "size") as? Int {
                    storageSize += size
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return storageSize
    }
    
}
