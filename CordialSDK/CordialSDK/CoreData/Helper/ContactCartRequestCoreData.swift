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
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let upsertContactCartRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactCartRequest, requiringSecureCoding: false)
                newRow.setValue(upsertContactCartRequestData, forKey: "data")
                
                try context.save()
            } catch {
                os_log("CoreData Error: Failed saving", log: OSLog.cordialError, type: .error)
            }
        }
    }
    
    func getContactCartRequestFromCoreData() -> UpsertContactCartRequest? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let anyData = data.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UpsertContactCartRequest {
                    CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                    
                    return sendCustomEventRequest
                }
            }
        } catch let error as NSError {
            os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
        
        return nil
    }
}
