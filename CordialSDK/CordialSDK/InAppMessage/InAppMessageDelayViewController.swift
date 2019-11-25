//
//  InAppMessageDelayViewController.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 25.11.2019.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import UIKit

@objc open class InAppMessageDelayViewController: UIViewController {

    @objc override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        InAppMessageProcess.shared.showInAppMessageIfPopupCanBePresented()
    }
}
