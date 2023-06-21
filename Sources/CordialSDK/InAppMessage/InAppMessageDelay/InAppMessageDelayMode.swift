//
//  InAppMessageDelayMode.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 11.11.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

@objcMembers public class InAppMessageDelayMode: NSObject {
    
    static let shared = InAppMessageDelayMode()
    
    private override init() {}
    
    var disallowedControllersType = [AnyObject.Type]()
    
    var currentMode = InAppMessageDelayType.show
    
    public func show(_ type: InAppMessageDelayShowType = .nextAppOpen) {
        self.currentMode = InAppMessageDelayType.show
        
        if type == .immediately {
            DispatchQueue.main.async {
                InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
            }
        }
    }
    
    public func delayedShow() {
        self.currentMode = InAppMessageDelayType.delayedShow
    }
    
    public func disallowedControllers(_ disallowedControllersType: [AnyObject.Type]) {
        self.currentMode = InAppMessageDelayType.disallowedControllers
        self.disallowedControllersType = disallowedControllersType
    }
}
