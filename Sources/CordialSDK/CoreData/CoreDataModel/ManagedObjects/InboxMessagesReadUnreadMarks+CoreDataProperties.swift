//
//  InboxMessagesReadUnreadMarks+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InboxMessagesReadUnreadMarks {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboxMessagesReadUnreadMarks> {
        return NSFetchRequest<InboxMessagesReadUnreadMarks>(entityName: "InboxMessagesReadUnreadMarks")
    }

    @NSManaged public var data: Data?
    @NSManaged public var date: Date?

}
