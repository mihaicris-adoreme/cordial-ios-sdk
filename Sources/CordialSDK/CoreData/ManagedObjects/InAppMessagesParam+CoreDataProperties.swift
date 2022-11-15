//
//  InAppMessagesParam+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 11.11.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesParam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesParam> {
        return NSFetchRequest<InAppMessagesParam>(entityName: "InAppMessagesParam")
    }

    @NSManaged public var bottom: Int16
    @NSManaged public var date: Date?
    @NSManaged public var displayType: String?
    @NSManaged public var expirationTime: Date?
    @NSManaged public var inactiveSessionDisplay: String?
    @NSManaged public var left: Int16
    @NSManaged public var mcID: String?
    @NSManaged public var right: Int16
    @NSManaged public var top: Int16
    @NSManaged public var type: String?

}
