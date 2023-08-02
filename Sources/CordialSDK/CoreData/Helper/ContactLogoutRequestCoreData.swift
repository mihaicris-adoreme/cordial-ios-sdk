//
//  ContactLogoutRequestCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactLogoutRequestCoreData {
    
    let entityName = "ContactLogout"
    
    // MARK: Setting Data
    
    func putContactLogoutRequest(sendContactLogoutRequest: SendContactLogoutRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let managedObject = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let sendContactLogoutRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactLogoutRequest, requiringSecureCoding: true)
                
                managedObject.setValue(sendContactLogoutRequestData, forKey: "data")
                managedObject.setValue(sendContactLogoutRequest.requestID, forKey: "requestID")
                managedObject.setValue(false, forKey: "flushing")
                
                CoreDataManager.shared.saveManagedObjectContext(context: context, entityName: self.entityName)
                
            } catch let error {
                CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    // MARK: Getting Data
    
    func fetchContactLogoutRequest() -> SendContactLogoutRequest? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return nil }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)

                    continue
                }
                
                if let sendContactLogoutRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [SendContactLogoutRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? SendContactLogoutRequest,
                   !sendContactLogoutRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        CoreDataManager.shared.saveManagedObjectContext(context: context, entityName: self.entityName)
                        
                        return sendContactLogoutRequest
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendContactLogoutRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
    
    // MARK: Removing Data
    
    func removeContactLogoutRequest(sendContactLogoutRequest: SendContactLogoutRequest) {
        let requestID = sendContactLogoutRequest.requestID
        
        CoreDataManager.shared.removeRequestObject(requestID: requestID, entityName: self.entityName)
    }
}
