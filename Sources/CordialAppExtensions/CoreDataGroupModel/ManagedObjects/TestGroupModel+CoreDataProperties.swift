//
//  TestGroupModel+CoreDataProperties.swift
//  CordialAppExtensions
//
//  Created by Yan Malinovsky on 09.11.2022.
//  Copyright © 2022 Cordial Experience, Inc. All rights reserved.
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
