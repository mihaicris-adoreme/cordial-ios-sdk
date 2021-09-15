//
//  ResourceBundle.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 13.09.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import class Foundation.Bundle

private class BundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var resourceBundle: Bundle = {
        let bundleName = "CordialSDK_CordialSDK"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named CordialSDK_CordialSDK")
    }()
}
