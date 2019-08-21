//
//  InAppMessagesQueueCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InAppMessagesQueueCoreData {
    
    let entityName = "InAppMessagesQueue"
    
    func setMcIdToCoreDataInAppMessagesQueue(mcID: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(mcID, forKey: "mcID")
                newRow.setValue(NSDate(), forKey: "date")
                
                try context.save()
            } catch let error {
                if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    func getMcIDsFromCoreDataInAppMessagesQueue() -> [String] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        var mcIDs = [String]()
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "mcID") else { continue }
                let mcID = anyData as! String
                
                mcIDs.append(mcID)
            }
        } catch let error {
            if OSLogManager.shared.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return mcIDs
    }
    
}
