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
            
            guard let isInboxMessageDeleteRequestExist = CoreDataManager.shared.isRequestObjectExist(requestID: requestID, entityName: self.entityName) else { return }
            
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
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
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
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessageDeleteRequestsFromCoreData() -> [InboxMessageDeleteRequest] {
        var inboxMessageDeleteRequests = [InboxMessageDeleteRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return inboxMessageDeleteRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let inboxMessageDeleteRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessageDeleteRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessageDeleteRequest,
                   !inboxMessageDeleteRequest.isError {
                    
                    inboxMessageDeleteRequests.append(inboxMessageDeleteRequest)
                } else {
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessageDeleteRequest", category: "CordialSDKError")
                }
                
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return inboxMessageDeleteRequests
    }
}
