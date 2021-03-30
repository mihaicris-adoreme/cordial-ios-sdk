//
//  CustomEventRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CustomEventRequestsCoreData {
    
    let entityName = "CustomEventRequest"
    
    func putCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        let qtyCachedCustomEventRequests = self.getQtyCachedCustomEventRequests()
        
        let sendCustomEventRequestsQty = qtyCachedCustomEventRequests + sendCustomEventRequests.count
        
        if sendCustomEventRequestsQty > CordialApiConfiguration.shared.qtyCachedEventQueue {
            let removeID = sendCustomEventRequestsQty - CordialApiConfiguration.shared.qtyCachedEventQueue
            self.removeFirstCustomEventRequestsFromCoreData(removeTo: removeID)
        }
        
        self.setCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
    }
    
    private func setCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            sendCustomEventRequests.forEach { sendCustomEventRequest in
                
                if !self.isCustomEventRequestExistAtCoreData(requestID: sendCustomEventRequest.requestID) {
                    
                    let newRow = NSManagedObject(entity: entity, insertInto: context)

                    do {
                        let sendCustomEventRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendCustomEventRequest, requiringSecureCoding: false)
                        
                        newRow.setValue(sendCustomEventRequestData, forKey: "data")
                        newRow.setValue(sendCustomEventRequest.requestID, forKey: "requestID")

                        try context.save()
                    } catch let error {
                        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                            os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                        }
                    }
                }
            }
        }
    }
    
    private func removeFirstCustomEventRequestsFromCoreData(removeTo id: Int){        
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        do {
            let result = try context.fetch(request)
            
            var countId = 0
            for managedObject in result as! [NSManagedObject] {
                if id > countId {
                    countId+=1
                    
                    context.delete(managedObject)
                    try context.save()
                } else {
                    break
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
    
    private func getCustomEventRequestsFromCoreData() -> [SendCustomEventRequest] {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        var sendCustomEventRequests = [SendCustomEventRequest]()
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SendCustomEventRequest, !sendCustomEventRequest.isError {
                    sendCustomEventRequests.append(sendCustomEventRequest)
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving SendCustomEventRequest", log: OSLog.cordialError, type: .error)
                    }
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }

        return sendCustomEventRequests
    }
    
    private func isCustomEventRequestExistAtCoreData(requestID: String) -> Bool {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "requestID = %@", requestID)
        request.predicate = predicate
        
        do {
            if let result = try context.fetch(request) as? [NSManagedObject], result.count > 0 {
                return true
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }

        return false
        
    }
    
    func fetchCustomEventRequestsFromCoreData() -> [SendCustomEventRequest] {
        let sendCustomEventRequests = self.getCustomEventRequestsFromCoreData()
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return sendCustomEventRequests
    }

    func getQtyCachedCustomEventRequests() -> Int {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let count = try context.count(for: request)
            
            return count
            
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return 0
    }
}
