//
//  InboxMessageDeleteCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InboxMessageDeleteCoreData {
    
    let entityName = "InboxMessageDeleteRequests"
    
    func putInboxMessageDeleteRequestToCoreData(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                if #available(iOS 11.0, *) {
                    let inboxMessageDeleteRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessageDeleteRequest, requiringSecureCoding: false)
            
                    newRow.setValue(inboxMessageDeleteRequestArchivedData, forKey: "data")
                } else {
                    let inboxMessageDeleteRequestArchivedData = NSKeyedArchiver.archivedData(withRootObject: inboxMessageDeleteRequest)
                    
                    newRow.setValue(inboxMessageDeleteRequestArchivedData, forKey: "data")
                }
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    func fetchInboxMessageDeleteRequestsFromCoreData() -> [InboxMessageDeleteRequest] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var inboxMessageDeleteRequests = [InboxMessageDeleteRequest]()
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let inboxMessageDeleteRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InboxMessageDeleteRequest, !inboxMessageDeleteRequest.isError {
                    inboxMessageDeleteRequests.append(inboxMessageDeleteRequest)
                } else {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving InboxMessageDeleteRequest", log: OSLog.cordialError, type: .error)
                    }
                }
                
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }

        return inboxMessageDeleteRequests
    }
}
