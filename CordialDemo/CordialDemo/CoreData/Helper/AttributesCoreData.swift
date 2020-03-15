//
//  AttributesCoreData.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 15.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class AttributesCoreData {
    
    let entityName = "Attributes"
    
    func setAttributeToCoreData(appDelegate: AppDelegate, attribute: Attribute) {
        let context = appDelegate.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(attribute.key, forKey: "key")
                newRow.setValue(attribute.type, forKey: "type")
                newRow.setValue(attribute.value, forKey: "value")
                
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    func getAttributesFromCoreData(appDelegate: AppDelegate) -> [Attribute] {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var attributes = [Attribute]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let key = data.value(forKey: "key") as? String, let type = data.value(forKey: "type") as? String, let value = data.value(forKey: "value") as? String {
                    
                    let attribute = Attribute(key: key, type: type, value: value)
                    
                    attributes.append(attribute)
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return attributes
    }
}
