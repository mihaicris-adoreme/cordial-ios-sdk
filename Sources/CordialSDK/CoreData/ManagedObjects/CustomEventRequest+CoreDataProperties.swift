//
//  CustomEventRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 29.10.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension CustomEventRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomEventRequest> {
        return NSFetchRequest<CustomEventRequest>(entityName: "CustomEventRequest")
    }

    @NSManaged public var data: Data?
    @NSManaged public var requestID: String?

}
