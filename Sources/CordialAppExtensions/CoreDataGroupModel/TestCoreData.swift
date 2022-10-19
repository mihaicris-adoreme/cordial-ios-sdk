//
//  TestCoreData.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 15.10.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
//

import Foundation
import CoreData
import os.log

// TMP
class TestCoreData {
    
    func test() {
        os_log("CordialSDK_AppExtensions: TestCoreData", log: .default, type: .error)
        
        let _ = CoreDataGroupManager.shared.managedObjectContext
        
    }
}

