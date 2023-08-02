//
//  InAppMessagesShownCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 05.12.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessagesShownCoreData {
    
    let entityName = "InAppMessagesShown"
    
    // MARK: Setting Data
    
    func putInAppMessageShown(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            managedObject.setValue(mcID, forKey: "mcID")
            
            CoreDataManager.shared.saveManagedObjectContext(context: context, entityName: self.entityName)
        }
    }
    
    // MARK: Getting Data
    
    func isInAppMessageShown(mcID: String) -> Bool? {
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
    
    func removeInAppMessageShown(mcID: String) {
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
