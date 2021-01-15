//
//  InboxMessagesContentCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 02.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InboxMessagesContentCoreData {
    
    let entityName = "InboxMessagesContent"
    
    func putInboxMessageContentToCoreData(mcID: String, content: String) {
        
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCacheSize > contentSize {
            
            if InboxMessageCache.shared.maxCacheSize > self.getInboxMessagesContentSizeAtCoreData() {
                self.saveInboxMessageContentToCoreData(mcID: mcID, content: content)
            } else {
                self.removeLastInboxMessageContentFromCoreData()
                
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                    os_log("Exceeded max cache size. Removing the firstest cached inbox message content to free storage capacity.", log: OSLog.cordialInboxMessages, type: .info)
                }
                
                self.putInboxMessageContentToCoreData(mcID: mcID, content: content)
            }
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Message didn't enter the cache. Message size exceeded max cache size.", log: OSLog.cordialInboxMessages, type: .info)
            }
        }
    }
    
    func getInboxMessageContentFromCoreData(mcID: String) -> String? {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return nil
    }
    
    func removeInboxMessageContentFromCoreData(mcID: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
    
    func removeLastInboxMessageContentFromCoreData() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
    
    private func saveInboxMessageContentToCoreData(mcID: String, content: String) {
        if let contentSize = content.data(using: .utf8)?.count,
           InboxMessageCache.shared.maxCachableMessageSize > contentSize {
            
            self.setInboxMessageContentToCoreData(mcID: mcID, content: content)
        } else {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .info) {
                os_log("Message didn't enter the cache. Message size exceeded max cacheable message size.", log: OSLog.cordialInboxMessages, type: .info)
            }
        }
    }
    
    private func setInboxMessageContentToCoreData(mcID: String, content: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newObject.setValue(mcID, forKey: "mcID")
                newObject.setValue(content, forKey: "content")
                newObject.setValue(content.data(using: .utf8)?.count, forKey: "size")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
    private func getInboxMessagesContentSizeAtCoreData() -> Int {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return storageSize
    }
    
}
