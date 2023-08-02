//
//  InAppMessagesQueueCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessagesQueueCoreData {
    
    let entityName = "InAppMessagesQueue"
    
    // MARK: Setting Data
    
    func putInAppMessageIDs(mcIDs: [String]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            mcIDs.forEach { mcID in
                if let date = CoreDataManager.shared.inAppMessagesParam.fetchInAppMessageDateParam(mcID: mcID) {
                    let managedObject = NSManagedObject(entity: entity, insertInto: context)
                    
                    managedObject.setValue(mcID, forKey: "mcID")
                    managedObject.setValue(date, forKey: "date")
                }
            }
            
            CoreDataManager.shared.saveManagedObjectContext(context: context, entityName: self.entityName)
        }
    }
    
    // MARK: Getting Data
    
    func fetchLatestInAppMessageID() -> String? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let mcID = managedObject.value(forKey: "mcID") as? String else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    continue
                }
                
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                
                return mcID
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
}
