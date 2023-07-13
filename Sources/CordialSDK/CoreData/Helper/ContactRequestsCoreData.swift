//
//  ContactRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/27/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactRequestsCoreData {
    
    let entityName = "ContactRequest"
    
    func setContactRequestsToCoreData(upsertContactRequests: [UpsertContactRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            upsertContactRequests.forEach { upsertContactRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    let upsertContactRequestData = try NSKeyedArchiver.archivedData(withRootObject: upsertContactRequest, requiringSecureCoding: true)
                    
                    newRow.setValue(upsertContactRequestData, forKey: "data")
                    
                    try context.save()
                } catch let error {
                    LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
                }
            }
        }
    }
    
    func getContactRequestsFromCoreData() -> [UpsertContactRequest] {
        var upsertContactRequests = [UpsertContactRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return upsertContactRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let upsertContactRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [UpsertContactRequest.self, NumericValue.self, BooleanValue.self, ArrayValue.self, StringValue.self, DateValue.self, GeoValue.self, JSONObjectValue.self, JSONObjectValues.self, JSONObjectsValues.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? UpsertContactRequest,
                   !upsertContactRequest.isError {
                    
                    upsertContactRequests.append(upsertContactRequest)
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    LoggerManager.shared.error(message: "Failed unarchiving UpsertContactRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return upsertContactRequests
    }
}
