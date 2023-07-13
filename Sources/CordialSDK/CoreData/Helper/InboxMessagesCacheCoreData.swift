//
//  InboxMessagesCacheCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessagesCacheCoreData {
    
    let entityName = "InboxMessagesCache"
    
    func putInboxMessageToCoreData(inboxMessage: InboxMessage) {
        guard let isInboxMessageExistInCoreData = self.isInboxMessageExistInCoreData(mcID: inboxMessage.mcID) else { return }
        
        if !isInboxMessageExistInCoreData {
            self.setInboxMessageToCoreData(inboxMessage: inboxMessage)
        } else {
            self.updateInboxMessageAtCoreData(inboxMessage: inboxMessage)
        }
    }
    
    func getInboxMessageFromCoreData(mcID: String) -> InboxMessage? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let inboxMessage = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessage.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessage,
                   !inboxMessage.isError {
    
                    return inboxMessage
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessage", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func removeInboxMessageFromCoreData(mcID: String) {
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
    
    private func setInboxMessageToCoreData(inboxMessage: InboxMessage) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newObject = NSManagedObject(entity: entity, insertInto: context)
            
            self.saveInboxMessageToCoreData(inboxMessage: inboxMessage, object: newObject, context: context)
        }
    }
    
    private func updateInboxMessageAtCoreData(inboxMessage: InboxMessage) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", inboxMessage.mcID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                self.saveInboxMessageToCoreData(inboxMessage: inboxMessage, object: managedObject, context: context)
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func saveInboxMessageToCoreData(inboxMessage: InboxMessage, object: NSManagedObject, context: NSManagedObjectContext) {
        do {
            let inboxMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessage, requiringSecureCoding: true)
    
            object.setValue(inboxMessageArchivedData, forKey: "data")
            object.setValue(inboxMessage.mcID, forKey: "mcID")
            
            try context.save()
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func isInboxMessageExistInCoreData(mcID: String) -> Bool? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            if let result = try context.fetch(request) as? [NSManagedObject], result.count > 0 {
                return true
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return false
    }
    
}
