//
//  CustomEventRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class CustomEventRequestsCoreData {
    
    let entityName = "CustomEventRequest"
    
    // MARK: Setting Data
    
    func putCustomEventRequests(sendCustomEventRequests: [SendCustomEventRequest]) {
        let sendCustomEventRequests = InternalCordialAPI().prepareCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)

        guard let cachedCustomEventRequestsQty = self.fetchCachedCustomEventRequestsQty() else { return }
        
        let countSendCustomEventRequests = sendCustomEventRequests.count
        
        let addingReporting = cachedCustomEventRequestsQty.addingReportingOverflow(countSendCustomEventRequests)
        
        if !addingReporting.overflow {
            let sendCustomEventRequestsQty = addingReporting.partialValue
            
            if sendCustomEventRequestsQty > CordialApiConfiguration.shared.qtyCachedEventQueue {
                let removeID = sendCustomEventRequestsQty - CordialApiConfiguration.shared.qtyCachedEventQueue
                self.removeFirstCustomEventRequests(removeTo: removeID)
            }
            
            self.setCustomEventRequests(sendCustomEventRequests: sendCustomEventRequests)
        }
    }
    
    private func setCustomEventRequests(sendCustomEventRequests: [SendCustomEventRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            for sendCustomEventRequest in sendCustomEventRequests {
                let requestID = sendCustomEventRequest.requestID
                
                guard let isCustomEventRequestExist = CoreDataManager.shared.isObjectExist(requestID: requestID, entityName: self.entityName) else { continue }
                
                if isCustomEventRequestExist {
                    self.updateCustomEventRequest(sendCustomEventRequest: sendCustomEventRequest)
                } else {
                    let managedObject = NSManagedObject(entity: entity, insertInto: context)
                    self.setCustomEventRequest(managedObject: managedObject, context: context, sendCustomEventRequest: sendCustomEventRequest)
                }
            }
        }
    }
    
    private func setCustomEventRequest(managedObject: NSManagedObject, context: NSManagedObjectContext, sendCustomEventRequest: SendCustomEventRequest) {
        do {
            let sendCustomEventRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendCustomEventRequest, requiringSecureCoding: true)
            
            managedObject.setValue(sendCustomEventRequestData, forKey: "data")
            managedObject.setValue(sendCustomEventRequest.requestID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateCustomEventRequest(sendCustomEventRequest: SendCustomEventRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", sendCustomEventRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setCustomEventRequest(managedObject: managedObject, context: context, sendCustomEventRequest: sendCustomEventRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchCustomEventRequests() -> [SendCustomEventRequest] {
        var sendCustomEventRequests = [SendCustomEventRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return sendCustomEventRequests }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return sendCustomEventRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)

                    continue
                }

                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [SendCustomEventRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? SendCustomEventRequest,
                   !sendCustomEventRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        sendCustomEventRequests.append(sendCustomEventRequest)
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendCustomEventRequest", category: "CordialSDKError")
                }
            }
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return sendCustomEventRequests
    }

    func fetchCachedCustomEventRequestsQty() -> Int? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let count = try context.count(for: request)
            
            return count
            
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeCustomEventRequests(sendCustomEventRequests: [SendCustomEventRequest]) {
        sendCustomEventRequests.forEach { sendCustomEventRequest in
            let requestID = sendCustomEventRequest.requestID
            
            CoreDataManager.shared.removeObject(requestID: requestID, entityName: self.entityName)
        }
    }
    
    private func removeFirstCustomEventRequests(removeTo id: Int) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            var countId = 0
            for managedObject in managedObjects {
                if id > countId {
                    countId += 1
                    
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                } else {
                    break
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(context: context, entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }

}
