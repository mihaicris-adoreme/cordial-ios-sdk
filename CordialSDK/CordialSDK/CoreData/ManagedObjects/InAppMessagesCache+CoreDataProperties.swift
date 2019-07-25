//
//  InAppMessagesCache+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/25/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesCache> {
        return NSFetchRequest<InAppMessagesCache>(entityName: "InAppMessagesCache")
    }

    @NSManaged public var data: NSData?
    @NSManaged public var date: NSDate?
    @NSManaged public var displayType: String?

}
