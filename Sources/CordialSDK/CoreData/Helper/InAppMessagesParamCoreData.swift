//
//  InAppMessagesParamCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InAppMessagesParamCoreData {
    
    let entityName = "InAppMessagesParam"
 
    func setParamsToCoreDataInAppMessagesParam(inAppMessagesParams: [InAppMessageParams]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            
            if !inAppMessagesParams.isEmpty {
                inAppMessagesParams.forEach { inAppMessageParams in
                    let newRow = NSManagedObject(entity: entity, insertInto: context)
                                
                    newRow.setValue(inAppMessageParams.mcID, forKey: "mcID")
                    newRow.setValue(inAppMessageParams.date, forKey: "date")
                    newRow.setValue(inAppMessageParams.type.rawValue, forKey: "type")
                    newRow.setValue(inAppMessageParams.top, forKey: "top")
                    newRow.setValue(inAppMessageParams.right, forKey: "right")
                    newRow.setValue(inAppMessageParams.bottom, forKey: "bottom")
                    newRow.setValue(inAppMessageParams.left, forKey: "left")
                    newRow.setValue(inAppMessageParams.displayType.rawValue, forKey: "displayType")
                    newRow.setValue(inAppMessageParams.expirationTime, forKey: "expirationTime")
                    newRow.setValue(inAppMessageParams.inactiveSessionDisplay.rawValue, forKey: "inactiveSessionDisplay")
                }
                
                do {
                    try context.save()
                } catch let error {
                    LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
                }
            }
        }
    }
    
    func getInAppMessageDateByMcID(mcID: String) -> Date? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let managedObjectDate = managedObject.value(forKey: "date") else { continue }
                let date = managedObjectDate as! Date
                
                return date
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func fetchInAppMessageParamsByMcID(mcID: String) -> InAppMessageParams? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {                
                guard let managedObjectDate = managedObject.value(forKey: "date") else { continue }
                let date = managedObjectDate as! Date
                
                let inAppMessageGetter = InAppMessageGetter()
                
                guard let managedObjectType = managedObject.value(forKey: "type") else { continue }
                let typeString = managedObjectType as! String
                let type = inAppMessageGetter.getInAppMessageType(typeString: typeString)
                
                guard let managedObjectTop = managedObject.value(forKey: "top") else { continue }
                let top = managedObjectTop as! Int16
                
                guard let managedObjectRight = managedObject.value(forKey: "right") else { continue }
                let right = managedObjectRight as! Int16
                
                guard let managedObjectBottom = managedObject.value(forKey: "bottom") else { continue }
                let bottom = managedObjectBottom as! Int16
                
                guard let managedObjectLeft = managedObject.value(forKey: "left") else { continue }
                let left = managedObjectLeft as! Int16
                
                guard let managedObjectDisplayType = managedObject.value(forKey: "displayType") else { continue }
                let displayTypeString = managedObjectDisplayType as! String
                let displayType = inAppMessageGetter.getInAppMessageDisplayType(displayTypeString: displayTypeString)
                
                let managedObjectExpirationTime = managedObject.value(forKey: "expirationTime") 
                let expirationTime = managedObjectExpirationTime as? Date

                guard let managedObjectInactiveSessionDisplay = managedObject.value(forKey: "inactiveSessionDisplay") else { continue }
                let inactiveSessionDisplayString = managedObjectInactiveSessionDisplay as! String
                let inactiveSessionDisplay = inAppMessageGetter.getInAppMessageInactiveSessionDisplayType(inactiveSessionDisplayString: inactiveSessionDisplayString)
                
                let inAppMessageParams = InAppMessageParams(mcID: mcID, date: date, type: type, top: top, right: right, bottom: bottom, left: left, displayType: displayType, expirationTime: expirationTime, inactiveSessionDisplay: inactiveSessionDisplay)
                
                return inAppMessageParams
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func deleteInAppMessageParamsByMcID(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
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
