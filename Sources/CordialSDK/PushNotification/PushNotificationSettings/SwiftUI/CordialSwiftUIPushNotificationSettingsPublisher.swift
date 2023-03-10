//
//  CordialSwiftUIPushNotificationSettingsPublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 10.03.2023.
//  Copyright © 2023 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIPushNotificationSettingsPublisher: ObservableObject {

    public static let shared = CordialSwiftUIPushNotificationSettingsPublisher()

    private init() {}
    
    public let emptySubject = PassthroughSubject<Empty<Int, Never>, Never>()
    
    func publishOpenPushNotificationSettings() -> Void {
        let empty = Empty<Int, Never>()
        
        self.emptySubject.send(empty)
    }
}
