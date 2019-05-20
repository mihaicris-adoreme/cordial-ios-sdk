//
//  CustomEventRequest+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/20/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension CustomEventRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CustomEventRequest> {
        return NSFetchRequest<CustomEventRequest>(entityName: "CustomEventRequest")
    }

    @NSManaged public var data: NSData?

}
