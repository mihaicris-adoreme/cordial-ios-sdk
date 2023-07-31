//
//  InAppMessageContentURLCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 16.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessageContentURLCoreData {
    
    let entityName = "InAppMessageContentURL"
    
    // MARK: Setting Data
    
    func putInAppMessageContent(inAppMessageContent: InAppMessageContent) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                managedObject.setValue(inAppMessageContent.mcID, forKey: "mcID")
                managedObject.setValue(inAppMessageContent.url, forKey: "url")
                managedObject.setValue(inAppMessageContent.expireDate, forKey: "expireDate")
                
                try context.save()
            } catch let error {
                CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchInAppMessageContent(mcID: String) -> InAppMessageContent? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "mcID = %@", mcID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let expireDate = managedObject.value(forKey: "expireDate") as? Date else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)

                    continue
                }
                
                guard let url = managedObject.value(forKey: "url") as? URL else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)

                    continue
                }
                
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                
                return InAppMessageContent(mcID: mcID, url: url, expireDate: expireDate)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
}
