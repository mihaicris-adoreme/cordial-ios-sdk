//
//  ContactLogoutRequestCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class ContactLogoutRequestCoreData {
    
    let entityName = "ContactLogout"
    
    func setContactLogoutRequestToCoreData(sendContactLogoutRequest: SendContactLogoutRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let sendContactLogoutRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactLogoutRequest, requiringSecureCoding: false)
                
                newRow.setValue(sendContactLogoutRequestData, forKey: "data")
                
                try context.save()
            } catch let error {
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    func getContactLogoutRequestFromCoreData() -> SendContactLogoutRequest? {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return nil }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let sendContactLogoutRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SendContactLogoutRequest, !sendContactLogoutRequest.isError {
                    CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
                    
                    return sendContactLogoutRequest
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendContactLogoutRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return nil
    }
}
