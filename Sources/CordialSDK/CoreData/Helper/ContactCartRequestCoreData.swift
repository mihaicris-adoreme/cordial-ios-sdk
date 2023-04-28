//
//  ContactCartRequestCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class ContactCartRequestCoreData {
    
    let entityName = "ContactCartRequest"
    
    func setContactCartRequestToCoreData(upsertContactCartRequest: UpsertContactCartRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let upsertContactCartRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactCartRequest, requiringSecureCoding: false)
                
                newRow.setValue(upsertContactCartRequestData, forKey: "data")
                
                try context.save()
            } catch let error {
                CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
    
    func getContactCartRequestFromCoreData() -> UpsertContactCartRequest? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UpsertContactCartRequest, !sendCustomEventRequest.isError {
                    CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                    
                    return sendCustomEventRequest
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    CordialApiConfiguration.shared.osLogManager.logging("Failed unarchiving UpsertContactCartRequest", log: OSLog.cordialError, type: .error)
                }
            }
        } catch let error {
            CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
        }
        
        return nil
    }
}
