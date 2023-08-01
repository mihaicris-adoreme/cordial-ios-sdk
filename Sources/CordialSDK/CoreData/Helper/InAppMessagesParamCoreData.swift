//
//  InAppMessagesParamCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessagesParamCoreData {
    
    let entityName = "InAppMessagesParam"
 
    // MARK: Setting Data
    
    func putInAppMessagesParams(inAppMessagesParams: [InAppMessageParams]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            inAppMessagesParams.forEach { inAppMessageParams in
                let managedObject = NSManagedObject(entity: entity, insertInto: context)
                            
                managedObject.setValue(inAppMessageParams.mcID, forKey: "mcID")
                managedObject.setValue(inAppMessageParams.date, forKey: "date")
                managedObject.setValue(inAppMessageParams.type.rawValue, forKey: "type")
                managedObject.setValue(inAppMessageParams.top, forKey: "top")
                managedObject.setValue(inAppMessageParams.right, forKey: "right")
                managedObject.setValue(inAppMessageParams.bottom, forKey: "bottom")
                managedObject.setValue(inAppMessageParams.left, forKey: "left")
                managedObject.setValue(inAppMessageParams.displayType.rawValue, forKey: "displayType")
                managedObject.setValue(inAppMessageParams.expirationTime, forKey: "expirationTime")
                managedObject.setValue(inAppMessageParams.inactiveSessionDisplay.rawValue, forKey: "inactiveSessionDisplay")
            }
            
            do {
                try context.save()
            } catch let error {
                CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchInAppMessageDateParam(mcID: String) -> Date? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let date = managedObject.value(forKey: "date") as? Date else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                return date
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func fetchInAppMessageParams(mcID: String) -> InAppMessageParams? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            let inAppMessageGetter = InAppMessageGetter()
            
            for managedObject in managedObjects {
                guard let date = managedObject.value(forKey: "date") as? Date else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                guard let typeString = managedObject.value(forKey: "type") as? String else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                let type = inAppMessageGetter.getInAppMessageType(typeString: typeString)
                
                guard let top = managedObject.value(forKey: "top") as? Int16 else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                guard let right = managedObject.value(forKey: "right") as? Int16 else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                guard let bottom = managedObject.value(forKey: "bottom") as? Int16 else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                guard let left = managedObject.value(forKey: "left") as? Int16 else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                guard let displayTypeString = managedObject.value(forKey: "displayType") as? String else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                let displayType = inAppMessageGetter.getInAppMessageDisplayType(displayTypeString: displayTypeString)
                
                let expirationTime = managedObject.value(forKey: "expirationTime") as? Date

                guard let inactiveSessionDisplayString = managedObject.value(forKey: "inactiveSessionDisplay") as? String else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                let inactiveSessionDisplay = inAppMessageGetter.getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
                
                let inAppMessageParams = InAppMessageParams(mcID: mcID, date: date, type: type, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
                
                return inAppMessageParams
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeInAppMessageParams(mcID: String) {
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
