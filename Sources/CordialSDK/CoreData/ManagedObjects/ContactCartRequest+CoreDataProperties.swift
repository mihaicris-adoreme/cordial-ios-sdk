//
//  ContactCartRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.07.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension ContactCartRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactCartRequest> {
        return NSFetchRequest<ContactCartRequest>(entityName: "ContactCartRequest")
    }

    @NSManaged public var data: Data?
    @NSManaged public var requestID: String?
    @NSManaged public var flushing: Bool

}
