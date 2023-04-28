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
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(mcID, forKey: "mcID")
                
                try context.save()
            } catch let error {
                CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
    
    func isInAppMessageHasBeenShown(mcID: String) -> Bool? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            if let result = try context.fetch(request) as? [NSManagedObject], !result.isEmpty {
                return true
            }
        } catch let error {
            CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
        }
        
        return false
    }
    
    func deleteInAppMessageShownStatusByMcID(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
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
            CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
        }
    }
}
