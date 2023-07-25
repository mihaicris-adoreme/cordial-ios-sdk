//
//  ContactCartRequestCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactCartRequestCoreData {
    
    let entityName = "ContactCartRequest"
    
    // MARK: Setting Data
    
    func putContactCartRequestToCoreData(upsertContactCartRequest: UpsertContactCartRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let upsertContactCartRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactCartRequest, requiringSecureCoding: true)
                
                managedObject.setValue(upsertContactCartRequestData, forKey: "data")
                managedObject.setValue(upsertContactCartRequest.requestID, forKey: "requestID")
                managedObject.setValue(false, forKey: "flushing")
                
                try context.save()
            } catch let error {
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchContactCartRequestFromCoreData() -> UpsertContactCartRequest? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)

                    continue
                }
                
                if let upsertContactCartRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UpsertContactCartRequest.self, CartItem.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? UpsertContactCartRequest,
                   !upsertContactCartRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        try context.save()
                        
                        return upsertContactCartRequest
                    }
                } else {
                    CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving UpsertContactCartRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeContactCartRequestFromCoreData(upsertContactCartRequest: UpsertContactCartRequest) {
        CoreDataManager.shared.removeRequestFromCoreData(requestID: upsertContactCartRequest.requestID, entityName: self.entityName)
    }
}
