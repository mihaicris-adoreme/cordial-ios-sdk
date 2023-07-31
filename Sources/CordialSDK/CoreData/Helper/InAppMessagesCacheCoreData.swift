//
//  InAppMessagesCacheCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessagesCacheCoreData {
    
    let entityName = "InAppMessagesCache"
    
    // MARK: Setting Data
    
    func putInAppMessageData(inAppMessageData: InAppMessageData) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            let mcID = inAppMessageData.mcID
            
            if let date = CoreDataManager.shared.inAppMessagesParam.getInAppMessageDateByMcID(mcID: mcID) {
                do {
                    let inAppMessageArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inAppMessageData, requiringSecureCoding: true)
                    
                    managedObject.setValue(mcID, forKey: "mcID")
                    managedObject.setValue(inAppMessageArchivedData, forKey: "data")
                    managedObject.setValue(date, forKey: "date")
                    managedObject.setValue(inAppMessageData.displayType.rawValue, forKey: "displayType")
                    
                    try context.save()
                } catch let error {
                    CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
                }
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchLatestInAppMessageData() -> InAppMessageData? {
        if let displayImmediatelyInAppMessageData = self.fetchDisplayImmediatelyInAppMessageData() {
            return displayImmediatelyInAppMessageData
        }
        
        if let displayOnAppOpenEventInAppMessageData = self.fetchDisplayOnAppOpenEventInAppMessageData() {
            return displayOnAppOpenEventInAppMessageData
        }
        
        return nil
    }
    
    func fetchDisplayImmediatelyInAppMessageData() -> InAppMessageData? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
        request.predicate = NSPredicate(format: "displayType = %@", InAppMessageDisplayType.displayImmediately.rawValue)
        
        return self.getInAppMessageData(request: request)
    }
    
    private func fetchDisplayOnAppOpenEventInAppMessageData() -> InAppMessageData? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        request.predicate = NSPredicate(format: "displayType = %@", InAppMessageDisplayType.displayOnAppOpenEvent.rawValue)
        
        return self.getInAppMessageData(request: request)
    }

    private func getInAppMessageData(request: NSFetchRequest<NSFetchRequestResult>) -> InAppMessageData? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)

                    continue
                }
                
                if let inAppMessageData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InAppMessageData.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InAppMessageData,
                   !inAppMessageData.isError {
                    
                    return inAppMessageData
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving InAppMessageData", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    func deleteInAppMessageDataByMcID(mcID: String) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
}
