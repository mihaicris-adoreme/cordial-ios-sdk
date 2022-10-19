//
//  ContactTimestampsURLCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class ContactTimestampsURLCoreData {
    
    let entityName = "ContactTimestampsURL"
    
    func putContactTimestampToCoreData(contactTimestamp: ContactTimestamp) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(contactTimestamp.url, forKey: "url")
                newRow.setValue(contactTimestamp.expireDate, forKey: "expireDate")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
    func getContactTimestampFromCoreData() -> ContactTimestamp? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let urlManagedObject = managedObject.value(forKey: "url") else { continue }
                let url = urlManagedObject as! URL
                
                guard let expireDateManagedObject = managedObject.value(forKey: "expireDate") else { continue }
                let expireDate = expireDateManagedObject as! Date
                
                return ContactTimestamp(url: url, expireDate: expireDate)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return nil
    }
    
    func removeContactTimestampFromCoreData() {
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
    }
    
}
