//
//  InboxMessagesMarkReadUnreadCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 07.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class InboxMessagesMarkReadUnreadCoreData {
    
    let entityName = "InboxMessagesReadUnreadMarks"
    
    func putInboxMessagesMarkReadUnreadRequest(inboxMessagesMarkReadUnreadRequest: InboxMessagesMarkReadUnreadRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            let newRow = NSManagedObject(entity: entity, insertInto: context)
            
            do {
                let inboxMessagesMarkReadUnreadRequestArchivedData = try NSKeyedArchiver.archivedData(withRootObject: inboxMessagesMarkReadUnreadRequest, requiringSecureCoding: true)
        
                newRow.setValue(inboxMessagesMarkReadUnreadRequestArchivedData, forKey: "data")
                newRow.setValue(inboxMessagesMarkReadUnreadRequest.date, forKey: "date")
                
                try context.save()
            } catch let error {
                CoreDataManager.shared.deleteAll(entityName: self.entityName)
                
                LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
            }
        }
    }
    
    func fetchInboxMessagesMarkReadUnreadRequests() -> [InboxMessagesMarkReadUnreadRequest] {
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

                if let inboxMessagesMarkReadUnreadRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [InboxMessagesMarkReadUnreadRequest.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? InboxMessagesMarkReadUnreadRequest,
                   !inboxMessagesMarkReadUnreadRequest.isError {
                    
                    inboxMessagesMarkReadUnreadRequests.append(inboxMessagesMarkReadUnreadRequest)
                } else {
                    LoggerManager.shared.error(message: "Failed unarchiving InboxMessagesMarkReadUnreadRequest", category: "CordialSDKError")
                }
                
                context.delete(managedObject)
                try context.save()
            }
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }

        return inboxMessagesMarkReadUnreadRequests
    }
}
