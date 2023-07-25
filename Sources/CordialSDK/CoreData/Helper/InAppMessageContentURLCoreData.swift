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
    
    func putInAppMessageContentToCoreData(inAppMessageContent: InAppMessageContent) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(inAppMessageContent.mcID, forKey: "mcID")
                newRow.setValue(inAppMessageContent.url, forKey: "url")
                newRow.setValue(inAppMessageContent.expireDate, forKey: "expireDate")
                
                try context.save()
            } catch let error {
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    func getInAppMessageContentFromCoreDataByMcID(mcID: String) -> InAppMessageContent? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
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
                
                CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                
                return InAppMessageContent(mcID: mcID, url: url, expireDate: expireDate)
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
}
