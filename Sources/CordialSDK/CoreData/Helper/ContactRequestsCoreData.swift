//
//  ContactRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactRequestsCoreData {
    
    let entityName = "ContactRequest"
    
    // MARK: Setting Data
    
    func putContactRequests(upsertContactRequests: [UpsertContactRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            for upsertContactRequest in upsertContactRequests {
                let requestID = upsertContactRequest.requestID
                
                guard let isUpsertContactRequestExist = CoreDataManager.shared.isRequestObjectExist(requestID: requestID, entityName: self.entityName) else { continue }
                
                if isUpsertContactRequestExist {
                    self.updateContactRequest(upsertContactRequest: upsertContactRequest)
                } else {
                    let managedObject = NSManagedObject(entity: entity, insertInto: context)
                    self.setContactRequest(managedObject: managedObject, context: context, upsertContactRequest: upsertContactRequest)
                }
            }
        }
    }
    
    private func setContactRequest(managedObject: NSManagedObject, context: NSManagedObjectContext, upsertContactRequest: UpsertContactRequest) {
        do {
            let upsertContactRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactRequest, requiringSecureCoding: true)
            
            managedObject.setValue(upsertContactRequestData, forKey: "data")
            managedObject.setValue(upsertContactRequest.requestID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")

            try context.save()
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateContactRequest(upsertContactRequest: UpsertContactRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", upsertContactRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setContactRequest(managedObject: managedObject, context: context, upsertContactRequest: upsertContactRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }

    // MARK: Getting Data
    
    func fetchContactRequests() -> [UpsertContactRequest] {
        var upsertContactRequests = [UpsertContactRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return upsertContactRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return upsertContactRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)

                    continue
                }
                
                if let upsertContactRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UpsertContactRequest.self, NumericValue.self, BooleanValue.self, ArrayValue.self, StringValue.self, DateValue.self, GeoValue.self, JSONObjectValue.self, JSONObjectValues.self, JSONObjectsValues.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? UpsertContactRequest,
                   !upsertContactRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        try context.save()
                        
                        upsertContactRequests.append(upsertContactRequest)
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving UpsertContactRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return upsertContactRequests
    }
    
    // MARK: Removing Data
    
    func removeContactRequests(upsertContactRequests: [UpsertContactRequest]) {
        upsertContactRequests.forEach { upsertContactRequest in
            CoreDataManager.shared.removeRequestObject(requestID: upsertContactRequest.requestID, entityName: self.entityName)
        }
    }
}
