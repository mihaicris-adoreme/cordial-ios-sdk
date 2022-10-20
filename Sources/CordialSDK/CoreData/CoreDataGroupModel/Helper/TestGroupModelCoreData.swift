//
//  TestGroupModelCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 20.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

public class TestGroupModelCoreData {
    
    let entityName = "TestGroupModel"
    
    public init() {}
    
    public func setTestGroupModelToCoreData(value: String) {
        let context = CoreDataGroupManager.shared.managedObjectContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(value, forKey: "test")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
}
