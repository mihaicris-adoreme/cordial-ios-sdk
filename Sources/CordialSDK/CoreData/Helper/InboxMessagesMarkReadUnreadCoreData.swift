//
//  InboxMessagesMarkReadUnreadCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 07.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessagesMarkReadUnreadCoreData {
    
    let entityName = "InboxMessagesReadUnreadMarks"
    
    // MARK: Setting Data
    
    func putInboxMessagesMarkReadUnreadRequest(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let requestID = inboxMessagesMarkReadUnreadRequest.requestID
            
            guard let isInboxMessagesMarkReadUnreadRequest = CoreDataManager.shared.isRequestObjectExist(requestID: requestID, entityName: self.entityName) else { return }
            
            if isInboxMessagesMarkReadUnreadRequest {
                self.updateInboxMessagesMarkReadUnreadRequest(inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            } else {
                let managedObject = NSManagedObject(entity: entity, insertInto: context)
                self.setInboxMessagesMarkReadUnreadRequest(managedObject: managedObject, context: context, inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            }
        }
    }
    
    private func setInboxMessagesMarkReadUnreadRequest(managedObject: NSManagedObject, context: NSManagedObjectContext, inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        do {
            let inboxMessagesMarkReadUnreadRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessagesMarkReadUnreadRequest, requiringSecureCoding: true)
    
            managedObject.setValue(inboxMessagesMarkReadUnreadRequestArchivedData, forKey: "data")
            managedObject.setValue(inboxMessagesMarkReadUnreadRequest.date, forKey: "date")
            managedObject.setValue(inboxMessagesMarkReadUnreadRequest.requestID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateInboxMessagesMarkReadUnreadRequest(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", inboxMessagesMarkReadUnreadRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setInboxMessagesMarkReadUnreadRequest(managedObject: managedObject, context: context, inboxMessagesMarkReadUnreadRequest: inboxMessagesMarkReadUnreadRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchInboxMessagesMarkReadUnreadRequests() -> [InboxMessagesMarkReadUnreadRequest] {
        var inboxMessagesMarkReadUnreadRequests = [InboxMessagesMarkReadUnreadRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return inboxMessagesMarkReadUnreadRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return inboxMessagesMarkReadUnreadRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    continue
                }

                if let inboxMessagesMarkReadUnreadRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessagesMarkReadUnreadRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessagesMarkReadUnreadRequest,
                   !inboxMessagesMarkReadUnreadRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        inboxMessagesMarkReadUnreadRequests.append(inboxMessagesMarkReadUnreadRequest)
                    }
                } else {
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessagesMarkReadUnreadRequest", category: "CordialSDKError")
                }
            }
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return inboxMessagesMarkReadUnreadRequests
    }
    
}
