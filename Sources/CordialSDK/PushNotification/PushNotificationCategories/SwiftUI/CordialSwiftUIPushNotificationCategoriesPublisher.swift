//
//  CordialSwiftUIPushNotificationCategoriesPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIPushNotificationCategoriesPublisher: ObservableObject {

    public static let shared = CordialSwiftUIPushNotificationCategoriesPublisher()

    private init() {}
    
    public let openPushNotificationCategories = PassthroughSubject<Empty<Int, Never>, Never>()
    
    func publishOpenPushNotificationCategories() -> Void {
        let empty = Empty<Int, Never>()
        
        self.openPushNotificationCategories.send(empty)
    }
}
