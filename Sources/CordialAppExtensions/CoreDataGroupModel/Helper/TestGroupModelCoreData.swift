//
//  TestGroupModelCoreData.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 20.10.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import CoreData
import os.log

class TestGroupModelCoreData {
        
    let entityName = "TestGroupModel"
    
    func getTestGroupModelToCoreData() -> String? {
        let context = CoreDataGroupManager.shared.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            
            for managedObject in result as! [NSManagedObject] {
                guard let urlManagedObject = managedObject.value(forKey: "test") else { continue }
                let test = urlManagedObject as! String
                
                context.delete(managedObject)
                try context.save()
                
                return test
            }
        } catch let error {
            os_log("CordialSDK_AppExtensions: CoreData Error [%{public}@] Entity: [%{public}@]", log: .default, type: .error, error.localizedDescription, self.entityName)
        }
        
        return nil
    }
    
}
