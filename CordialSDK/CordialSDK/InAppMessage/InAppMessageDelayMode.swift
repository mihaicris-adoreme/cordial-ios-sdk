//
//  InAppMessageDelayMode.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 11.11.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objc public class InAppMessageDelayMode: NSObject {
    
    var disallowedControllersType = [AnyObject.Type]()
    
    var currentMode = InAppMessageDelayType.show
    
    @objc public func show() {
        self.currentMode = InAppMessageDelayType.show
    }
    
    @objc public func delayedShow() {
        self.currentMode = InAppMessageDelayType.delayedShow
    }
    
    @objc public func disallowedControllers(_ disallowedControllersType: [AnyObject.Type]) {
        self.currentMode = InAppMessageDelayType.disallowedControllers
        self.disallowedControllersType = disallowedControllersType
    }
}
