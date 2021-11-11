//
//  InAppMessagesCacheCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InAppMessagesCacheCoreData {
    
    let entityName = "InAppMessagesCache"
    
    func setInAppMessageDataToCoreData(inAppMessageData: InAppMessageData) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            let mcID = inAppMessageData.mcID
            
            if let date = CoreDataManager.shared.inAppMessagesParam.getInAppMessageDateByMcID(mcID: mcID) {
                do {
                    let inAppMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inAppMessageData, requiringSecureCoding: false)
                    
                    newRow.setValue(mcID, forKey: "mcID")
                    newRow.setValue(inAppMessageArchivedData, forKey: "data")
                    newRow.setValue(date, forKey: "date")
                    newRow.setValue(inAppMessageData.displayType.rawValue, forKey: "displayType")
                    
                    try context.save()
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                    }
                }
            }
        }
    }
    
    func getLatestInAppMessageDataFromCoreData() -> InAppMessageData? {
        if let displayImmediatelyInAppMessageData = self.getDisplayImmediatelyInAppMessageDataFromCoreData() {
            return displayImmediatelyInAppMessageData
        }
        
        if let displayOnAppOpenEventInAppMessageData = self.getDisplayOnAppOpenEventInAppMessageDataFromCoreData() {
            return displayOnAppOpenEventInAppMessageData
        }
        
        return nil
    }
    
    func getDisplayImmediatelyInAppMessageDataFromCoreData() -> InAppMessageData? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
            
        request.predicate = NSPredicate(format: "displayType = %@", InAppMessageDisplayType.displayImmediately.rawValue)
        
        return self.getInAppMessageData(request: request)
    }
    
    private func getDisplayOnAppOpenEventInAppMessageDataFromCoreData() -> InAppMessageData? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "displayType = %@", InAppMessageDisplayType.displayOnAppOpenEvent.rawValue)
        
        return self.getInAppMessageData(request: request)
    }

    private func getInAppMessageData(request: NSFetchRequest<NSFetchRequestResult>) -> InAppMessageData? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let inAppMessageData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InAppMessageData, !inAppMessageData.isError {
                    return inAppMessageData
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving InAppMessageData", log: OSLog.cordialError, type: .error)
                    }
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
        
        return nil
    }
    
    func deleteInAppMessageDataByMcID(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }
    }
}
