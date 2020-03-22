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
    
    func putAttributeToCoreData(appDelegate: AppDelegate, attribute: Attribute) {
        if self.isExistedAttributeWithKey(appDelegate: appDelegate, key: attribute.key) {
            self.modifyExistingAttribute(appDelegate: appDelegate, attribute: attribute)
        } else {
            self.addNewAttributeToCoreData(appDelegate: appDelegate, attribute: attribute)
        }
    }
    
    private func addNewAttributeToCoreData(appDelegate: AppDelegate, attribute: Attribute) {
        let context = appDelegate.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(attribute.key, forKey: "key")
                newRow.setValue(attribute.type.rawValue, forKey: "type")
                newRow.setValue(Attribute.performArrayToStringSeparatedByComma(attribute.value), forKey: "value")
                
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    private func modifyExistingAttribute(appDelegate: AppDelegate, attribute: Attribute) {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "key == %@", attribute.key)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let attributeData = result.first as! NSManagedObject
                attributeData.setValue(attribute.type.rawValue, forKey: "type")
                attributeData.setValue(Attribute.performArrayToStringSeparatedByComma(attribute.value), forKey: "value")
                
                try context.save()
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
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
                    
                    switch type {
                    case AttributeType.string.rawValue:
                        let attribute = Attribute(key: key, type: AttributeType.string, value: value)
                        attributes.append(attribute)
                    case AttributeType.boolean.rawValue:
                        let attribute = Attribute(key: key, type: AttributeType.boolean, value: value)
                        attributes.append(attribute)
                    case AttributeType.numeric.rawValue:
                        let attribute = Attribute(key: key, type: AttributeType.numeric, value: value)
                        attributes.append(attribute)
                    case AttributeType.array.rawValue:
                        let attribute = Attribute(key: key, type: AttributeType.array, value: value)
                        attributes.append(attribute)
                    case AttributeType.date.rawValue:
                        let attribute = Attribute(key: key, type: AttributeType.date, value: value)
                        attributes.append(attribute)
                    default:
                        break
                    }
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return attributes
    }
    
    func isExistedAttributeWithKey(appDelegate: AppDelegate, key: String) -> Bool {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "key == %@", key)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count > 0 {
                return true
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return false
    }
    
    func deleteAttributeByKey(appDelegate: AppDelegate, key: String) {
        let context = appDelegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        deleteFetch.predicate = NSPredicate(format: "key == %@", key)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
