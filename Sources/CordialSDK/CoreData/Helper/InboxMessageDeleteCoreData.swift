//
//  InboxMessageDeleteCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessageDeleteCoreData {
    
    let entityName = "InboxMessageDeleteRequests"
    
    // MARK: Setting Data
    
    func putInboxMessageDeleteRequest(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let requestID = inboxMessageDeleteRequest.requestID
            
            guard let isInboxMessageDeleteRequestExist = CoreDataManager.shared.isObjectExist(requestID: requestID, entityName: self.entityName) else { return }
            
            if isInboxMessageDeleteRequestExist {
                self.updateInboxMessageDeleteRequest(inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            } else {
                let managedObject = NSManagedObject(entity: entity, insertInto: context)
                self.setInboxMessageDeleteRequest(managedObject: managedObject, context: context, inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            }
        }
    }
    
    private func setInboxMessageDeleteRequest(managedObject: NSManagedObject, context: NSManagedObjectContext, inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        do {
            let inboxMessageDeleteRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessageDeleteRequest, requiringSecureCoding: true)
    
            managedObject.setValue(inboxMessageDeleteRequestArchivedData, forKey: "data")
            managedObject.setValue(inboxMessageDeleteRequest.requestID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateInboxMessageDeleteRequest(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", inboxMessageDeleteRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setInboxMessageDeleteRequest(managedObject: managedObject, context: context, inboxMessageDeleteRequest: inboxMessageDeleteRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessageDeleteRequests() -> [InboxMessageDeleteRequest] {
        var inboxMessageDeleteRequests = [InboxMessageDeleteRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return inboxMessageDeleteRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return inboxMessageDeleteRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    continue
                }

                if let inboxMessageDeleteRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessageDeleteRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessageDeleteRequest,
                   !inboxMessageDeleteRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        inboxMessageDeleteRequests.append(inboxMessageDeleteRequest)
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessageDeleteRequest", category: "CordialSDKError")
                }
            }
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return inboxMessageDeleteRequests
    }
    
    // MARK: Removing Data
    
    func removeInboxMessageDeleteRequest(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        let requestID = inboxMessageDeleteRequest.requestID
        
        CoreDataManager.shared.removeObject(requestID: requestID, entityName: self.entityName)
    }
}
