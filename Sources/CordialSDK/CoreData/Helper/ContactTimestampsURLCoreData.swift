//
//  ContactTimestampsURLCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 04.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactTimestampsURLCoreData {
    
    let entityName = "ContactTimestampsURL"
    
    // MARK: Setting Data
    
    func putContactTimestamp(contactTimestamp: ContactTimestamp) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAll(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            managedObject.setValue(contactTimestamp.url, forKey: "url")
            managedObject.setValue(contactTimestamp.expireDate, forKey: "expireDate")
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
        }
    }
    
    // MARK: Getting Data
    
    func fetchContactTimestamp() -> ContactTimestamp? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let url = managedObject.value(forKey: "url") as? URL else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    continue
                }
                guard let expireDate = managedObject.value(forKey: "expireDate") as? Date else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    continue
                }
                
                return ContactTimestamp(url: url, expireDate: expireDate)
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeContactTimestamp() {
        CoreDataManager.shared.deleteAll(entityName: self.entityName)
    }
    
}
