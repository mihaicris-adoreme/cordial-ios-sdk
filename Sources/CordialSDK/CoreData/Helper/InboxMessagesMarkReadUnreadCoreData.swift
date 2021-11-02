//
//  InboxMessagesMarkReadUnreadCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 07.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class InboxMessagesMarkReadUnreadCoreData {
    
    let entityName = "InboxMessagesReadUnreadMarks"
    
    func putInboxMessagesMarkReadUnreadDataToCoreData(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let inboxMessagesMarkReadUnreadRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessagesMarkReadUnreadRequest, requiringSecureCoding: false)
        
                newRow.setValue(inboxMessagesMarkReadUnreadRequestArchivedData, forKey: "data")
                newRow.setValue(inboxMessagesMarkReadUnreadRequest.date, forKey: "date")
                
                try context.save()
            } catch let error {
                if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                    os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
                }
            }
        }
    }
    
    func fetchInboxMessagesMarkReadUnreadDataFromCoreData() -> [InboxMessagesMarkReadUnreadRequest] {
        var inboxMessagesMarkReadUnreadRequests = [InboxMessagesMarkReadUnreadRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return inboxMessagesMarkReadUnreadRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let inboxMessagesMarkReadUnreadRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? InboxMessagesMarkReadUnreadRequest, !inboxMessagesMarkReadUnreadRequest.isError {
                    inboxMessagesMarkReadUnreadRequests.append(inboxMessagesMarkReadUnreadRequest)
                } else {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("Failed unarchiving InboxMessagesMarkReadUnreadRequest", log: OSLog.cordialError, type: .error)
                    }
                }
                
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@] Entity: [%{public}@]", log: OSLog.cordialCoreDataError, type: .error, error.localizedDescription, self.entityName)
            }
        }

        return inboxMessagesMarkReadUnreadRequests
    }
}
