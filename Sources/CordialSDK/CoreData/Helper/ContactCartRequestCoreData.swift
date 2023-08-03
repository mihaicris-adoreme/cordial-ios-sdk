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
    
    func putContactCartRequest(upsertContactCartRequest: UpsertContactCartRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAll(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let upsertContactCartRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactCartRequest, requiringSecureCoding: true)
                
                managedObject.setValue(upsertContactCartRequestData, forKey: "data")
                managedObject.setValue(upsertContactCartRequest.requestID, forKey: "requestID")
                managedObject.setValue(false, forKey: "flushing")
                
                CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
                
            } catch let error {
                CoreDataManager.shared.deleteAll(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchContactCartRequest() -> UpsertContactCartRequest? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)

                    continue
                }
                
                if let upsertContactCartRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UpsertContactCartRequest.self, CartItem.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? UpsertContactCartRequest,
                   !upsertContactCartRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
                        
                        return upsertContactCartRequest
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving UpsertContactCartRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeContactCartRequest(upsertContactCartRequest: UpsertContactCartRequest) {
        let requestID = upsertContactCartRequest.requestID
        
        CoreDataManager.shared.removeRequestObject(requestID: requestID, entityName: self.entityName)
    }
}
