//
//  ContactTimestampsURL+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.03.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactTimestampsURL {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactTimestampsURL> {
        return NSFetchRequest<ContactTimestampsURL>(entityName: "ContactTimestampsURL")
    }

    @NSManaged public var expireDate: Date?
    @NSManaged public var url: URL?

}
