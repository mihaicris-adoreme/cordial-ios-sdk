//
//  ContactRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class ContactRequestsCoreData {
    
    let entityName = "ContactRequest"
    
    func setContactRequestsToCoreData(upsertContactRequests: [UpsertContactRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            upsertContactRequests.forEach { upsertContactRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    let upsertContactRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactRequest, requiringSecureCoding: false)
                    
                    newRow.setValue(upsertContactRequestData, forKey: "data")
                    
                    try context.save()
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                    }
                }
            }
        }
    }
    
    func getContactRequestsFromCoreData() -> [UpsertContactRequest] {
        var upsertContactRequests = [UpsertContactRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return upsertContactRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let upsertContactRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UpsertContactRequest, !upsertContactRequest.isError {
                    upsertContactRequests.append(upsertContactRequest)
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving UpsertContactRequest", log: OSLog.cordialError, type: .error)
                    }
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return upsertContactRequests
    }
}
