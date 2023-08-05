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
    
    // MARK: Setting Data
    
    func putInboxMessage(inboxMessage: InboxMessage) {
        guard let isInboxMessageExist = CoreDataManager.shared.isRequestObjectExist(mcID: inboxMessage.mcID, entityName: self.entityName) else { return }
        
        if !isInboxMessageExist {
            self.setInboxMessage(inboxMessage: inboxMessage)
        } else {
            self.updateInboxMessage(inboxMessage: inboxMessage)
        }
    }
    
    private func setInboxMessage(inboxMessage: InboxMessage) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newObject = NSManagedObject(entity: entity, insertInto: context)
            
            self.saveInboxMessage(inboxMessage: inboxMessage, object: newObject, context: context)
        }
    }
    
    private func updateInboxMessage(inboxMessage: InboxMessage) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "mcID = %@", inboxMessage.mcID)
        request.predicate = predicate
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                self.saveInboxMessage(inboxMessage: inboxMessage, object: managedObject, context: context)
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func saveInboxMessage(inboxMessage: InboxMessage, object: NSManagedObject, context: NSManagedObjectContext) {
        do {
            let inboxMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessage, requiringSecureCoding: true)
    
            object.setValue(inboxMessageArchivedData, forKey: "data")
            object.setValue(inboxMessage.mcID, forKey: "mcID")
            
            try context.save()
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessage(mcID: String) -> InboxMessage? {
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
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeInboxMessage(mcID: String) {
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
    
}
