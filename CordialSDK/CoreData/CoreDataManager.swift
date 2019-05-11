//
//  CoreDataManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    public static let shared = CoreDataManager()
    
    private init(){}
    
    let modelName = "CoreDataModel"
    
    let customEventRequests = CustomEventRequestsCoreData()
    let contactCartRequest = ContactCartRequestCoreData()
    let contactOrderRequests = ContactOrderRequestsCoreData()
    let contactRequests = ContactRequestsCoreData()
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let bundle = Bundle(for: type(of: self))
        let modelURL = bundle.url(forResource: self.modelName, withExtension: "momd")!
        let objectModel = NSManagedObjectModel(contentsOf: modelURL)!
        
        let container = NSPersistentContainer(name: self.modelName, managedObjectModel: objectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    func deleteAllCoreDataByEntity(entityName: String) {
        let context = persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func deleteAllCoreData() {
        self.deleteAllCoreDataByEntity(entityName: customEventRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactCartRequest.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactOrderRequests.entityName)
        self.deleteAllCoreDataByEntity(entityName: contactRequests.entityName)
    }
    
}
