//
//  ContactLogout+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 27.07.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactLogout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactLogout> {
        return NSFetchRequest<ContactLogout>(entityName: "ContactLogout")
    }

    @NSManaged public var data: Data?
    @NSManaged public var flushing: Bool
    @NSManaged public var requestID: String?

}
