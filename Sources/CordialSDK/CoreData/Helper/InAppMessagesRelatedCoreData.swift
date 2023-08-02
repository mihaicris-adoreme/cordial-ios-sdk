//
//  InAppMessagesRelatedCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.12.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessagesRelatedCoreData {
    
    let entityName = "InAppMessagesRelated"
    
    // MARK: Setting Data
    
    func putInAppMessageRelated(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                managedObject.setValue(mcID, forKey: "mcID")
                
                try context.save()
            } catch let error {
                CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func isInAppMessageRelated(mcID: String) -> Bool? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            if let managedObjects = try context.fetch(request) as? [NSManagedObject],
               !managedObjects.isEmpty {
                
                return true
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return false
    }
    
    // MARK: Removing Data
    
    func removeInAppMessageRelated(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }

}
