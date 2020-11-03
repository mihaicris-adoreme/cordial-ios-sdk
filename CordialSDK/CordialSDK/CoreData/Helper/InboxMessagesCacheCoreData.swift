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
        if !self.isInboxMessageExistAtCoreData(mcID: inboxMessage.mcID) {
            self.putInboxMessageToCoreData(inboxMessage: inboxMessage)
        }
    }
    
    private func setInboxMessageToCoreData(inboxMessage: InboxMessage) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                if #available(iOS 11.0, *) {
                    let inboxMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessage, requiringSecureCoding: false)
            
                    newRow.setValue(inboxMessageArchivedData, forKey: "data")
                    newRow.setValue(inboxMessage.mcID, forKey: "mcID")
                } else {
                    let inboxMessageArchivedData = NSKeyedArchiver.archivedData(withRootObject: inboxMessage)
                    
                    newRow.setValue(inboxMessageArchivedData, forKey: "data")
                    newRow.setValue(inboxMessage.mcID, forKey: "mcID")
                }
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    private func isInboxMessageExistAtCoreData(mcID: String) -> Bool {
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
