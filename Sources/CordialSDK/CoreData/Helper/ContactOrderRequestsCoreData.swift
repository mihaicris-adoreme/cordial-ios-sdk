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
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
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
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
    }
    
    // MARK: Getting Data
    
    func fetchContactOrderRequests() -> [SendContactOrderRequest] {
        var sendContactOrderRequests = [SendContactOrderRequest]()
        
        guard let context = CoreDataManager.shared.persistentContainer?.viewContext else { return sendContactOrderRequests }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.entityName)
        request.returnsObjectsAsFaults = false
        
        do {
            guard let managedObjects = try context.fetch(request) as? [NSManagedObject] else { return sendContactOrderRequests }
            
            for managedObject in managedObjects {
                guard let data = managedObject.value(forKey: "data") as? Data else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)

                    continue
                }
                
                if let sendContactOrderRequest = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [SendContactOrderRequest.self, Order.self, Address.self, CartItem.self] + API.DEFAULT_UNARCHIVER_CLASSES, from: data) as? SendContactOrderRequest,
                   !sendContactOrderRequest.isError {
                    
                    guard let isFlushing = managedObject.value(forKey: "flushing") as? Bool else {
                        CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                        
                        continue
                    }
                    
                    if !isFlushing {
                        managedObject.setValue(true, forKey: "flushing")
                        
                        sendContactOrderRequests.append(sendContactOrderRequest)
                    }
                } else {
                    CoreDataManager.shared.removeManagedObject(managedObject: managedObject, context: context, entityName: self.entityName)
                    
                    LoggerManager.shared.error(message: "Failed unarchiving SendContactOrderRequest", category: "CordialSDKError")
                }
            }
            
            CoreDataManager.shared.saveContext(context: context, entityName: self.entityName)
            
        } catch let error {
            CoreDataManager.shared.deleteAll(entityName: self.entityName)
            
            LoggerManager.shared.error(message: "CoreData Error: [\(error.localizedDescription)] Entity: [\(self.entityName)]", category: "CordialSDKCoreDataError")
        }
        
        return sendContactOrderRequests
    }
    
    // MARK: Removing Data
    
    func removeContactOrderRequests(sendContactOrderRequests: [SendContactOrderRequest]) {
        sendContactOrderRequests.forEach { sendContactOrderRequest in
            let requestID = sendContactOrderRequest.order.orderID
            
            CoreDataManager.shared.removeRequestObject(requestID: requestID, entityName: self.entityName)
        }
    }
}
