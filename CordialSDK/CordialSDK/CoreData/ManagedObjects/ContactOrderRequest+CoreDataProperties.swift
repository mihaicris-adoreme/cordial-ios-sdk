//
//  ContactOrderRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactOrderRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactOrderRequest> {
        return NSFetchRequest<ContactOrderRequest>(entityName: "ContactOrderRequest")
    }

    @NSManaged public var data: NSData?

}
