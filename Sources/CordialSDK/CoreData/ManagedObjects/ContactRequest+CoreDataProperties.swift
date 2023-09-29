//
//  ContactRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 19.07.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactRequest> {
        return NSFetchRequest<ContactRequest>(entityName: "ContactRequest")
    }

    @NSManaged public var data: Data?
    @NSManaged public var requestID: String?
    @NSManaged public var flushing: Bool

}
