//
//  InboxMessagesCacheCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InboxMessagesCacheCoreData {
    
    let entityName = "InboxMessagesCache"
    
    func putInboxMessageToCoreData(inboxMessage: InboxMessage) {
        if !self.isInboxMessageExistInCoreData(mcID: inboxMessage.mcID) {
            self.setInboxMessageToCoreData(inboxMessage: inboxMessage)
        } else {
            self.updateInboxMessageAtCoreData(inboxMessage: inboxMessage)
        }
    }
    
    private func setInboxMessageToCoreData(inboxMessage: InboxMessage) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newObject = NSManagedObject(entity: entity, insertInto: context)
            
            self.saveInboxMessageToCoreData(inboxMessage: inboxMessage, object: newObject, context: context)
        }
    }
    
    private func updateInboxMessageAtCoreData(inboxMessage: InboxMessage) {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
    }
    
    private func saveInboxMessageToCoreData(inboxMessage: InboxMessage, object: NSManagedObject, context: NSManagedObjectContext) {
        do {
            if #available(iOS 11.0, *) {
                let inboxMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessage, requiringSecureCoding: false)
        
                object.setValue(inboxMessageArchivedData, forKey: "data")
                object.setValue(inboxMessage.mcID, forKey: "mcID")
            } else {
                let inboxMessageArchivedData = NSKeyedArchiver.archivedData(withRootObject: inboxMessage)
                
                object.setValue(inboxMessageArchivedData, forKey: "data")
                object.setValue(inboxMessage.mcID, forKey: "mcID")
            }
            
            try context.save()
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
    }
    
    private func isInboxMessageExistInCoreData(mcID: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext

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
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }

        return false
    }
    
}
