//
//  ContactOrderRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class ContactOrderRequestsCoreData {
    
    let entityName = "ContactOrderRequest"
    
    func setContactOrderRequestsToCoreData(sendContactOrderRequests: [SendContactOrderRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            sendContactOrderRequests.forEach { sendContactOrderRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    let sendContactOrderRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactOrderRequest, requiringSecureCoding: false)
                    
                    newRow.setValue(sendContactOrderRequestData, forKey: "data")
                    
                    try context.save()
                } catch let error {
                    CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
    func getContactOrderRequestsFromCoreData() -> [SendContactOrderRequest] {
        var sendContactOrderRequests = [SendContactOrderRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return sendContactOrderRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let sendContactOrderRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SendContactOrderRequest, !sendContactOrderRequest.isError {
                    sendContactOrderRequests.append(sendContactOrderRequest)
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    CordialApiConfiguration.shared.osLogManager.logging("Failed unarchiving SendContactOrderRequest", log: OSLog.cordialError, type: .error)
                }
            }
        } catch let error {
            CordialApiConfiguration.shared.osLogManager.logging("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return sendContactOrderRequests
    }
}
