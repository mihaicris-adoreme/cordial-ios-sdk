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
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            upsertContactRequests.forEach { upsertContactRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    let upsertContactRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactRequest, requiringSecureCoding: false)
                    newRow.setValue(upsertContactRequestData, forKey: "data")
                    
                    try context.save()
                } catch {
                    os_log("CoreData Error: Failed saving", log: OSLog.cordialError, type: .error)
                }
            }
        }
    }
    
    func getContactRequestsFromCoreData() -> [UpsertContactRequest] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var upsertContactRequests = [UpsertContactRequest]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let anyData = data.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let upsertContactRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UpsertContactRequest {
                    upsertContactRequests.append(upsertContactRequest)
                }
            }
        } catch let error as NSError {
            os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return upsertContactRequests
    }
}
