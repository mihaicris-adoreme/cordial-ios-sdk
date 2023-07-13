//
//  CustomEventRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 26.06.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
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
    @NSManaged public var flushing: Bool

}
