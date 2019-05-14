//
//  ContactOrderRequestsCoreData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class ContactOrderRequestsCoreData {
    
    let entityName = "ContactOrderRequest"
    
    func setContactOrderRequestsToCoreData(sendContactOrderRequests: [SendContactOrderRequest]) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            sendContactOrderRequests.forEach { sendContactOrderRequest in
                let newRow = NSManagedObject(entity: entity, insertInto: context)
                
                do {
                    let sendContactOrderRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactOrderRequest, requiringSecureCoding: false)
                    newRow.setValue(sendContactOrderRequestData, forKey: "data")
                    
                    try context.save()
                } catch {
                    print("Failed saving")
                }
            }
        }
    }
    
    func getContactOrderRequestsFromCoreData() -> [SendContactOrderRequest] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        var sendContactOrderRequests = [SendContactOrderRequest]()
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let anyData = data.value(forKey: "data") else { continue }
                let data = anyData as! Data
                
                if let sendContactOrderRequest = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SendContactOrderRequest {
                    sendContactOrderRequests.append(sendContactOrderRequest)
                }
            }
        } catch let error as NSError {
            print("Failed: \(error) \(error.userInfo)")
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return sendContactOrderRequests
    }
}
