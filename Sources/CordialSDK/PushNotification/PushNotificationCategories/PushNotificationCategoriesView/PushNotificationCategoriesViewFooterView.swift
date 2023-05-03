//
//  PushNotificationCategoriesViewFooterView.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 24.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import UIKit

class PushNotificationCategoriesViewFooterView: UIView {

    // Forward all the touches through this overlay view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            !$0.isHidden && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }

}
