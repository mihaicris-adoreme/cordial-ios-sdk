//
//  InAppMessageBannerView.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/18/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

class InAppMessageBannerView: UIView {
    
    // Forward all the touches through this overlay view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.contains(where: {
            !$0.isHidden && $0.point(inside: self.convert(point, to: $0), with: event)
        })
    }

}
