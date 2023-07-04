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
    
    func putCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        guard let qtyCachedCustomEventRequests = self.getQtyCachedCustomEventRequests() else { return }
        
        let countSendCustomEventRequests = sendCustomEventRequests.count
        
        let addingReporting = qtyCachedCustomEventRequests.addingReportingOverflow(countSendCustomEventRequests)
        
        if !addingReporting.overflow {
            let sendCustomEventRequestsQty = addingReporting.partialValue
            
            if sendCustomEventRequestsQty > CordialApiConfiguration.shared.qtyCachedEventQueue {
                let removeID = sendCustomEventRequestsQty - CordialApiConfiguration.shared.qtyCachedEventQueue
                self.removeFirstCustomEventRequestsFromCoreData(removeTo: removeID)
            }
            
            self.setCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
        }
    }
    
    func removeCustomEventRequestsFromCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        sendCustomEventRequests.forEach { sendCustomEventRequests in
            self.removeCustomEventRequestFromCoreData(sendCustomEventRequest: sendCustomEventRequests)
        }
    }
    
    func updateSendingCustomEventRequestsIfNeeded() {
        if InternalCordialAPI().isUserLogin() {
            DispatchQueue.main.async {
                self.updateSendingCustomEventRequests()
            }
        }
    }
    
    private func updateSendingCustomEventRequests() {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSBatchUpdateRequest(entityName: self.entityName)
        request.resultType = .statusOnlyResultType
        
        request.predicate = NSPredicate(format: "flushing = %@", NSNumber(value: true))
        request.propertiesToUpdate = ["flushing": NSNumber(value: false)]
        
        do {
            try context.execute(request)
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func setCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            for sendCustomEventRequest in sendCustomEventRequests {
                guard let isCustomEventRequestExistAtCoreData = self.isCustomEventRequestExistAtCoreData(requestID: sendCustomEventRequest.requestID) else { continue }
                
                if isCustomEventRequestExistAtCoreData {
                    self.updateCustomEventRequestsAtCoreData(sendCustomEventRequest: sendCustomEventRequest)
                } else {
                    let managedObject = NSManagedObject(entity: entity, insertInto: context)
                    self.setCustomEventRequestToCoreData(managedObject: managedObject, context: context, sendCustomEventRequest: sendCustomEventRequest)
                }
            }
        }
    }
    
    private func setCustomEventRequestToCoreData(managedObject: NSManagedObject, context: NSManagedObjectContext, sendCustomEventRequest: SendCustomEventRequest) {
        do {
            let sendCustomEventRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendCustomEventRequest, requiringSecureCoding: true)
            
            managedObject.setValue(sendCustomEventRequestData, forKey: "data")
            managedObject.setValue(sendCustomEventRequest.requestID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")

            try context.save()
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateCustomEventRequestsAtCoreData(sendCustomEventRequest: SendCustomEventRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", sendCustomEventRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setCustomEventRequestToCoreData(managedObject: managedObject, context: context, sendCustomEventRequest: sendCustomEventRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func removeCustomEventRequestFromCoreData(sendCustomEventRequest: SendCustomEventRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", sendCustomEventRequest.requestID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func removeFirstCustomEventRequestsFromCoreData(removeTo id: Int) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            var countId = 0
            for managedObject in managedObjects {
                if id > countId {
                    countId+=1
                    
                    CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                } else {
                    break
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    func getCustomEventRequestsFromCoreData() -> [SendCustomEventRequest] {
        var sendCustomEventRequests = [SendCustomEventRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return sendCustomEventRequests }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return sendCustomEventRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)

                    continue
                }

                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [SendCustomEventRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? SendCustomEventRequest,
                   !sendCustomEventRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        try context.save()
                        
                        sendCustomEventRequests.append(sendCustomEventRequest)
                    }
                } else {
                    CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendCustomEventRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return sendCustomEventRequests
    }
    
    private func isCustomEventRequestExistAtCoreData(requestID: String) -> Bool? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        let predicate = NSPredicate(format: "requestID = %@", requestID)
        request.predicate = predicate
        
        do {
            if let managedObjects = try context.fetch(request) as? [NSManagedObject],
               managedObjects.count > 0 {
                
                return true
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return false
        
    }

    func getQtyCachedCustomEventRequests() -> Int? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let count = try context.count(for: request)
            
            return count
            
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
}
