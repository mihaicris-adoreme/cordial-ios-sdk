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
    
    // MARK: Setting Data
    
    func putContactOrderRequests(sendContactOrderRequests: [SendContactOrderRequest]) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }
        
        if let entity = NSEntityDescription.entity(forEntityName: self.entityName, in: context) {
            for sendContactOrderRequest in sendContactOrderRequests {
                let requestID = sendContactOrderRequest.order.orderID
                
                guard let isContactOrderRequestExist = CoreDataManager.shared.isRequestObjectExist(requestID: requestID, entityName: self.entityName) else { continue }
                
                if isContactOrderRequestExist {
                    self.updateContactOrderRequest(sendContactOrderRequest: sendContactOrderRequest)
                } else {
                    let managedObject = NSManagedObject(entity: entity, insertInto: context)
                    self.setContactOrderRequest(managedObject: managedObject, context: context, sendContactOrderRequest: sendContactOrderRequest)
                }
            }
        }
    }
    
    private func setContactOrderRequest(managedObject: NSManagedObject, context: NSManagedObjectContext, sendContactOrderRequest: SendContactOrderRequest) {
        do {
            let sendContactOrderRequestData = try NSKeyedArchiver.archivedData(withRootObject: sendContactOrderRequest, requiringSecureCoding: true)
            
            managedObject.setValue(sendContactOrderRequestData, forKey: "data")
            managedObject.setValue(sendContactOrderRequest.order.orderID, forKey: "requestID")
            managedObject.setValue(false, forKey: "flushing")
            
            try context.save()
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    private func updateContactOrderRequest(sendContactOrderRequest: SendContactOrderRequest) {
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        request.predicate = NSPredicate(format: "requestID = %@", sendContactOrderRequest.order.orderID)
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return }
            
            for managedObject in managedObjects {
                self.setContactOrderRequest(managedObject: managedObject, context: context, sendContactOrderRequest: sendContactOrderRequest)
            }
        } catch let error {
            CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
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
                
                if let sendContactOrderRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [SendContactOrderRequest.self, Order.self, Address.self, CartItem.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? SendContactOrderRequest,
                   !sendContactOrderRequest.isError {
                    
                    sendContactOrderRequests.append(sendContactOrderRequest)
                } else {
                    context.delete(managedObject)
                    try context.save()
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendContactOrderRequest", category: "CordialSDKError")
                }
            }
        } catch let error {
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        CoreDataManager.shared.deleteAllCoreDataByEntity(entityName: self.entityName)
        
        return sendContactOrderRequests
    }
    
    // MARK: Removing Data
}
