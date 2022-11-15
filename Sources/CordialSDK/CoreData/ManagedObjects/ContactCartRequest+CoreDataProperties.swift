//
//  ContactCartRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactCartRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactCartRequest> {
        return NSFetchRequest<ContactCartRequest>(entityName: "ContactCartRequest")
    }

    @NSManaged public var data: NSData?

}
