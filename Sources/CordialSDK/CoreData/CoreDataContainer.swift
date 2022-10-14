//
//  CoreDataContainer.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//

import Foundation
import CoreData

class CoreDataContainer: NSPersistentContainer {
    
    override class func defaultDirectoryURL() -> URL {
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: API.SECURITY_APPLICATION_GROUP_IDENTIFIER)!
        
        return storeURL.appendingPathComponent("\(CoreDataManager.shared.modelName).sqlite")
    }

}
