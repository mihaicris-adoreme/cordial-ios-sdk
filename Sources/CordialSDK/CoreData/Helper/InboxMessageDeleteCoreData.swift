//
//  InboxMessageDeleteCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessageDeleteCoreData {
    
    let entityName = "InboxMessageDeleteRequests"
    
    func putInboxMessageDeleteRequestToCoreData(inboxMessageDeleteRequest: InboxMessageDeleteRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let inboxMessageDeleteRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessageDeleteRequest, requiringSecureCoding: true)
        
                newRow.setValue(inboxMessageDeleteRequestArchivedData, forKey: "data")
                
                try context.save()
            } catch let error {
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    func fetchInboxMessageDeleteRequestsFromCoreData() -> [InboxMessageDeleteRequest] {
        var inboxMessageDeleteRequests = [InboxMessageDeleteRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return inboxMessageDeleteRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for managedObject in result as! [NSManagedObject] {
                guard let anyData = managedObject.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let inboxMessageDeleteRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessageDeleteRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessageDeleteRequest,
                   !inboxMessageDeleteRequest.isError {
                    
                    inboxMessageDeleteRequests.append(inboxMessageDeleteRequest)
                } else {
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessageDeleteRequest", category: "CordialSDKError")
                }
                
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return inboxMessageDeleteRequests
    }
}
