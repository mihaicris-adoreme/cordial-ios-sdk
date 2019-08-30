//
//  CustomEventRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData
import os.log

class CustomEventRequestsCoreData {
    
    let entityName = "CustomEventRequest"
    
    func putCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        let cachedSendCustomEventRequests = self.getCustomEventRequestsFromCoreData()
        
        let sendCustomEventRequestsQty = cachedSendCustomEventRequests.count + sendCustomEventRequests.count
        
        if sendCustomEventRequestsQty > CordialApiConfiguration.shared.qtyCachedEventQueue {
            let removeID = sendCustomEventRequestsQty - CordialApiConfiguration.shared.qtyCachedEventQueue
            self.removeFirstCustomEventRequestsFromCoreData(removeTo: removeID)
        }
        
        self.setCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
    }
    
    func setCustomEventRequestsToCoreData(sendCustomEventRequests: [SendCustomEventRequest]) {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            sendCustomEventRequests.forEach { sendCustomEventRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)

                do {
                    if #available(iOS 11.0, *) {
                        let sendCustomEventRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendCustomEventRequest, requiringSecureCoding: false)
                        
                        newRow.setValue(sendCustomEventRequestData, forKey: "data")
                    } else {
                        let sendCustomEventRequestData = NSKeyedArchiver.archivedData(withRootObject: sendCustomEventRequest)
                        
                        newRow.setValue(sendCustomEventRequestData, forKey: "data")
                    }

                    try context.save()
                } catch let error {
                    if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                        os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func removeFirstCustomEventRequestsFromCoreData(removeTo id: Int){
        var sendCustomEventRequests = self.getCustomEventRequestsFromCoreData()
        if sendCustomEventRequests.count > 0 {
            sendCustomEventRequests.removeFirst(id)
            
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            self.setCustomEventRequestsToCoreData(sendCustomEventRequests: sendCustomEventRequests)
        }
    }
    
    func getCustomEventRequestsFromCoreData() -> [SendCustomEventRequest] {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false

        var sendCustomEventRequests = [SendCustomEventRequest]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let anyData = data.value(forKey: "data") else { continue }
                let data = anyData as! Data

                if let sendCustomEventRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SendCustomEventRequest {
                    sendCustomEventRequests.append(sendCustomEventRequest)
                }
            }
        } catch let error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("CoreData Error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }

        return sendCustomEventRequests
    }
    
    func fetchCustomEventRequestsFromCoreData() -> [SendCustomEventRequest] {
        let sendCustomEventRequests = self.getCustomEventRequestsFromCoreData()
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return sendCustomEventRequests
    }

}
