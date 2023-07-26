//
//  ContactOrderRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.07.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactOrderRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactOrderRequest> {
        return NSFetchRequest<ContactOrderRequest>(entityName: "ContactOrderRequest")
    }

    @NSManaged public var data: Data?
    @NSManaged public var requestID: String?
    @NSManaged public var flushing: Bool

}
