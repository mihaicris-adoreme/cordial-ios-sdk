//
//  InAppMessageContentURLCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 16.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InAppMessageContentURLCoreData {
    
    let entityName = "InAppMessageContentURL"
    
    func putInAppMessageContentToCoreData(inAppMessageContent: InAppMessageContent) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(inAppMessageContent.mcID, forKey: "mcID")
                newRow.setValue(inAppMessageContent.url, forKey: "url")
                newRow.setValue(inAppMessageContent.expireDate, forKey: "expireDate")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
    func getInAppMessageContentFromCoreDataByMcID(mcID: String) -> InAppMessageContent? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            if let result = try context.fetch(request) as? [NSManagedObject],
               !result.isEmpty,
               let managedObject = result.first {
                
                guard let expireDateManagedObject = managedObject.value(forKey: "expireDate") else { return nil }
                let expireDate = expireDateManagedObject as! Date
                
                guard let urlManagedObject = managedObject.value(forKey: "url") else { return nil }
                let url = urlManagedObject as! URL
                
                context.delete(managedObject)
                try context.save()
                
                return InAppMessageContent(mcID: mcID, url: url, expireDate: expireDate)
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return nil
    }
    
}
