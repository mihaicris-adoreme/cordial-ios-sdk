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
    
    func setMcIDsToCoreDataInAppMessagesQueue(mcIDs: [String]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            
            if !mcIDs.isEmpty {
                mcIDs.forEach { mcID in
                    
                    DispatchQueue.main.async {
                        if let date = CoreDataManager.shared.inAppMessagesParam.getInAppMessageDateByMcID(mcID: mcID) {
                            
                            ThreadQueues.shared.queueInAppMessage.sync(flags: .barrier) {
                                let newRow = NSManagedObject(entity: entity, insertInto: context)
                                
                                newRow.setValue(mcID, forKey: "mcID")
                                newRow.setValue(date, forKey: "date")
                                
                                do {
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
            }
        }
    }
    
    func getMcIdFromCoreDataInAppMessagesQueue() -> String? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "mcID") else { continue }
                let mcID = anyData as! String
                
                CoreDataManager.shared.deleteManagedObjectByContext(managedObject: managedObject, context: context)
                
                return mcID
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return nil
    }
    
}
