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
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let mcID = inboxMessage.mcID
            
            guard let isInboxMessageExist = CoreDataManager.shared.isObjectExist(mcID: mcID, entityName: self.entityName) else { return }
            
            if isInboxMessageExist {
                self.updateInboxMessage(inboxMessage: inboxMessage)
            } else {
                let managedObject = NSManagedObject(entity: entity, insertInto: context)
                self.setInboxMessage(managedObject: managedObject, context: context, inboxMessage: inboxMessage)
            }
        }
    }
    
    private func setInboxMessage(managedObject: NSManagedObject, context: NSManagedObjectContext, inboxMessage: InboxMessage) {
        do {
            let inboxMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessage, requiringSecureCoding: true)

            managedObject.setValue(inboxMessageArchivedData, forKey: "data")
            managedObject.setValue(inboxMessage.mcID, forKey: "mcID")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateInboxMessage(inboxMessage: InboxMessage) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "mcID = %@", inboxMessage.mcID)
        request.predicate = predicate
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setInboxMessage(managedObject: managedObject, context: context, inboxMessage: inboxMessage)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessage(mcID: String) -> InboxMessage? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "mcID = %@", mcID)
        request.predicate = predicate
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    continue
                }
                
                if let inboxMessage = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessage.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessage,
                   !inboxMessage.isError {
    
                    return inboxMessage
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessage", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeInboxMessage(mcID: String) {
        CoreDataManager.shared.removeObject(mcID: mcID, entityName: self.entityName)
    }
    
}
