//
//  CordialURLSessionData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/17/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class CordialURLSessionData {
    
    let taskName: String
    let taskData: AnyObject
    
    init(taskName: String, taskData: AnyObject) {
        self.taskName = taskName
        self.taskData = taskData
    }
}
