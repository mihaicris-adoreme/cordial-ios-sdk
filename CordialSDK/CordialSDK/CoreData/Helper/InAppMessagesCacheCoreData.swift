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
                
                try context.save()
            } catch {
                os_log("CoreData Error: Failed saving", log: OSLog.cordialError, type: .error)
            }
        }
    }
    
    func getInAppMessageDataFromCoreData() -> InAppMessageData? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
                
                guard let anyData = data.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let inAppMessageData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InAppMessageData {
                    return inAppMessageData
                }
            }
        } catch let error as NSError {
            os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
        
        return nil
    }

}
