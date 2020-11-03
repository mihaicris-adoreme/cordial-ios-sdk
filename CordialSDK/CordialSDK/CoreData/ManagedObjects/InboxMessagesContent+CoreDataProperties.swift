//
//  InboxMessagesContent+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 03.11.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InboxMessagesContent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboxMessagesContent> {
        return NSFetchRequest<InboxMessagesContent>(entityName: "InboxMessagesContent")
    }

    @NSManaged public var content: String?

}
