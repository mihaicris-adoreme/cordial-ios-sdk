//
//  InboxMessagesCache+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InboxMessagesCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboxMessagesCache> {
        return NSFetchRequest<InboxMessagesCache>(entityName: "InboxMessagesCache")
    }

    @NSManaged public var data: Data?
    @NSManaged public var mcID: String?

}
