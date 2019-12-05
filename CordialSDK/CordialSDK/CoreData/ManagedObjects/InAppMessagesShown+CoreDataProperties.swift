//
//  InAppMessagesShown+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 05.12.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessagesShown {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessagesShown> {
        return NSFetchRequest<InAppMessagesShown>(entityName: "InAppMessagesShown")
    }

    @NSManaged public var mcID: String?

}
