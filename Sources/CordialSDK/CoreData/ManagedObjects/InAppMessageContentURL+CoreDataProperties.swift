//
//  InAppMessageContentURL+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension InAppMessageContentURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InAppMessageContentURL> {
        return NSFetchRequest<InAppMessageContentURL>(entityName: "InAppMessageContentURL")
    }

    @NSManaged public var expireDate: Date?
    @NSManaged public var mcID: String?
    @NSManaged public var url: URL?

}
