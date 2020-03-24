//
//  AttributeGeoCoreData.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 24.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class AttributeGeoCoreData {
    
    let entityName = "AttributeGeo"
    
    func putGeoAttributeToCoreData(appDelegate: AppDelegate, geoAttribute: GeoAttribute) {
        if self.isExistedGeoAttributeWithKey(appDelegate: appDelegate, key: geoAttribute.key) {
            self.modifyExistingGeoAttribute(appDelegate: appDelegate, geoAttribute: geoAttribute)
        } else {
            self.addNewGeoAttributeToCoreData(appDelegate: appDelegate, geoAttribute: geoAttribute)
        }
    }
    
    private func addNewGeoAttributeToCoreData(appDelegate: AppDelegate, geoAttribute: GeoAttribute) {
        let context = appDelegate.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                newRow.setValue(geoAttribute.key, forKey: "key")
                newRow.setValue(geoAttribute.city, forKey: "city")
                newRow.setValue(geoAttribute.country, forKey: "country")
                newRow.setValue(geoAttribute.postalCode, forKey: "postalCode")
                newRow.setValue(geoAttribute.state, forKey: "state")
                newRow.setValue(geoAttribute.streetAdress, forKey: "streetAdress")
                newRow.setValue(geoAttribute.streetAdress2, forKey: "streetAdress2")
                newRow.setValue(geoAttribute.timeZone, forKey: "timeZone")
                
                try context.save()
            } catch {
                print("Failed saving")
            }
        }
    }
    
    private func modifyExistingGeoAttribute(appDelegate: AppDelegate, geoAttribute: GeoAttribute) {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.predicate = NSPredicate(format: "key == %@", geoAttribute.key)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            if result.count == 1 {
                let geoAttributeData = result.first as! NSManagedObject
                geoAttributeData.setValue(geoAttribute.city, forKey: "city")
                geoAttributeData.setValue(geoAttribute.country, forKey: "country")
                geoAttributeData.setValue(geoAttribute.postalCode, forKey: "postalCode")
                geoAttributeData.setValue(geoAttribute.state, forKey: "state")
                geoAttributeData.setValue(geoAttribute.streetAdress, forKey: "streetAdress")
                geoAttributeData.setValue(geoAttribute.streetAdress2, forKey: "streetAdress2")
                geoAttributeData.setValue(geoAttribute.timeZone, forKey: "timeZone")
                
                try context.save()
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
    }
    
    func getAttributesFromCoreData(appDelegate: AppDelegate) -> [GeoAttribute] {
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var geoAttributes = [GeoAttribute]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let key = data.value(forKey: "key") as? String,
                    let city = data.value(forKey: "city") as? String,
                    let country = data.value(forKey: "country") as? String,
                    let postalCode = data.value(forKey: "postalCode") as? String,
                    let state = data.value(forKey: "state") as? String,
                    let streetAdress = data.value(forKey: "streetAdress") as? String,
                    let streetAdress2 = data.value(forKey: "streetAdress2") as? String,
                    let timeZone = data.value(forKey: "timeZone") as? String {
                    
                    let geoAttribute = GeoAttribute(key: key, city: city, country: country, postalCode: postalCode, state: state, streetAdress: streetAdress, streetAdress2: streetAdress2, timeZone: timeZone)
                    
                    geoAttributes.append(geoAttribute)
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        return geoAttributes
    }
    
    func isExistedGeoAttributeWithKey(appDelegate: AppDelegate, key: String) -> Bool {
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
    
    func deleteGeoAttributeByKey(appDelegate: AppDelegate, key: String) {
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
