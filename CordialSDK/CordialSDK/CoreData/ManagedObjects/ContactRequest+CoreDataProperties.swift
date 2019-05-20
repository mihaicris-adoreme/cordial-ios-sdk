//
//  ContactRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactRequest> {
        return NSFetchRequest<ContactRequest>(entityName: "ContactRequest")
    }

    @NSManaged public var data: NSData?

}
