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
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                if #available(iOS 11.0, *) {
                    let sendContactLogoutRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactLogoutRequest, requiringSecureCoding: false)
                    
                    newRow.setValue(sendContactLogoutRequestData, forKey: "data")
                } else {
                    let sendContactLogoutRequestData = NSKeyedArchiver.archivedData(withRootObject: sendContactLogoutRequest)
                    
                    newRow.setValue(sendContactLogoutRequestData, forKey: "data")
                }
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    func getContactLogoutRequestFromCoreData() -> SendContactLogoutRequest? {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
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
                    
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving SendContactLogoutRequest", log: OSLog.cordialError, type: .error)
                    }
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
        
        return nil
    }
}
