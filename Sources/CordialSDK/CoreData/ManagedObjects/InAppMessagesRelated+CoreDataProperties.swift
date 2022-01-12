//
//  InAppMessagesRelated+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 06.12.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesRelated {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesRelated> {
        return NSFetchRequest<InAppMessagesRelated>(entityName: "InAppMessagesRelated")
    }

    @NSManaged public var mcID: String?

}
