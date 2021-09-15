//
//  InAppMessagesQueue+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/5/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesQueue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesQueue> {
        return NSFetchRequest<InAppMessagesQueue>(entityName: "InAppMessagesQueue")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var mcID: String?

}
