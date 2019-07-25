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
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let inAppMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inAppMessageData, requiringSecureCoding: false)
                newRow.setValue(inAppMessageArchivedData, forKey: "data")
                newRow.setValue(NSDate(), forKey: "date")
                newRow.setValue(inAppMessageData.displayType.rawValue, forKey: "displayType")
                
                try context.save()
            } catch {
                os_log("CoreData Error: Failed saving", log: OSLog.cordialError, type: .error)
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
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let inAppMessageData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InAppMessageData {
                    context.delete(managedObject)
                    try context.save()
                    
                    return inAppMessageData
                }
            }
        } catch let error as NSError {
            os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
        
        return nil
    }
}
