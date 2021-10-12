//
//  ContactLogout+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactLogout {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactLogout> {
        return NSFetchRequest<ContactLogout>(entityName: "ContactLogout")
    }

    @NSManaged public var data: NSData?

}
