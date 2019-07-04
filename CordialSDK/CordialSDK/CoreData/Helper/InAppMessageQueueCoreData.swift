//
//  InAppMessageQueueCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InAppMessageQueueCoreData {
    
    let entityName = "InAppMessageQueue"
    
    func setInAppMessageQueueToCoreData(mcID: String) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(mcID, forKey: "mcID")
                newRow.setValue(NSDate(), forKey: "date")
                
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    func getInAppMessagesQueueFromCoreData() -> [String] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        
        var mcIDs = [String]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                context.delete(data)
                
                guard let anyData = data.value(forKey: "mcID") else { continue }
                let mcID = anyData as! String
                
                mcIDs.append(mcID)
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return mcIDs
    }
    
}
