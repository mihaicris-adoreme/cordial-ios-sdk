//
//  ProfileTableFooterView.swift
//  CordialDemo
//
//  Created by Yan Malinovsky on 11.03.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import UIKit
import CordialSDK

class ProfileTableFooterView: UITableViewHeaderFooterView {
    
    @IBAction func updateProfileAction(_ sender: UIButton) {
        let attributes = ["key": ArrayValue(["q", "w", "e"])]
//            let attributes = ["key": StringValue("TEST")]
//            let attributes = ["key": BooleanValue(true)]
//            let attributes = ["key": NumericValue(1.3)]
//            let attributes = ["key": NumericValue(1)]

        CordialAPI().upsertContact(attributes: attributes)

        if let controller = getActiveViewController() {
            popupSimpleNoteAlert(title: "PROFILE", message: "UPDATED", controller: controller)
        }
    }    
}
