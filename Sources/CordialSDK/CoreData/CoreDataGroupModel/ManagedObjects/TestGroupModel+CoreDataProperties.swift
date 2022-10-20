//
//  TestGroupModel+CoreDataProperties.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 20.10.2022.
//  Copyright © 2022 cordial.io. All rights reserved.
//
//

import Foundation
import CoreData


extension TestGroupModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestGroupModel> {
        return NSFetchRequest<TestGroupModel>(entityName: "TestGroupModel")
    }

    @NSManaged public var test: String?

}
