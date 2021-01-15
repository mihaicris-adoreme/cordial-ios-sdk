//
//  InboxMessageDeleteRequests+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 14.09.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InboxMessageDeleteRequests {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InboxMessageDeleteRequests> {
        return NSFetchRequest<InboxMessageDeleteRequests>(entityName: "InboxMessageDeleteRequests")
    }

    @NSManaged public var data: Data?

}
