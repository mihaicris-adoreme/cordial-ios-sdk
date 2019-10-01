//
//  InAppMessagesCache+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/26/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesCache> {
        return NSFetchRequest<InAppMessagesCache>(entityName: "InAppMessagesCache")
    }

    @NSManaged public var data: Data?
    @NSManaged public var date: Date?
    @NSManaged public var displayType: String?
    @NSManaged public var mcID: String?

}
