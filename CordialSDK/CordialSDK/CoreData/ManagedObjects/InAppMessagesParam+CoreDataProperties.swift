//
//  InAppMessagesParam+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 9/10/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesParam {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesParam> {
        return NSFetchRequest<InAppMessagesParam>(entityName: "InAppMessagesParam")
    }

    @NSManaged public var mcID: String?
    @NSManaged public var date: NSDate?

}
