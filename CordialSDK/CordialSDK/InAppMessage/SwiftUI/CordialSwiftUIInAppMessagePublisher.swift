//
//  CordialSwiftUIInAppMessagePublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIInAppMessagePublisher: ObservableObject {
    
    public static let shared = CordialSwiftUIInAppMessagePublisher()

    private init() {}
    
    public let inputsCaptured = PassthroughSubject<CordialSwiftUIInAppMessageInputsCaptured, Never>()
    
    func publishInputsCaptured(eventName: String, properties: Dictionary<String, Any>) {
        let inputsCaptured = CordialSwiftUIInAppMessageInputsCaptured(eventName: eventName, properties: properties)
        
        self.inputsCaptured.send(inputsCaptured)
    }
    
}
