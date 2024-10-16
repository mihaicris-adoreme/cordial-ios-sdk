//
//  CordialSwiftUIDeepLinks.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 12.07.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

public struct CordialSwiftUIDeepLinks {
    public let deepLink: CordialDeepLink
    public let fallbackURL: URL?
    public let completionHandler: (CordialDeepLinkActionType) -> Void
}
