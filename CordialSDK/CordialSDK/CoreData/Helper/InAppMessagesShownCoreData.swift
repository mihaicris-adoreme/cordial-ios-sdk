//
//  InAppMessagesShownCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 05.12.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InAppMessagesShownCoreData {
    
    let entityName = "InAppMessagesShown"
    
    func setShownStatusToInAppMessagesShownCoreData(mcID: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(mcID, forKey: "mcID")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    func isInAppMessageHasBeenShown(mcID: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            if let result = try context.fetch(request) as? [NSManagedObject], !result.isEmpty {
                return true
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
        
        return false
    }
    
    func deleteInAppMessagesShownStatusByMcID(mcID: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
    }
}
