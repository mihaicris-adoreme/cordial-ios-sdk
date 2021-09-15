//
//  CordialSwiftUIInboxMessagePublisher.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 22.07.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class CordialSwiftUIInboxMessagePublisher: ObservableObject {
    
    public static let shared = CordialSwiftUIInboxMessagePublisher()

    private init() {}
    
    public let newInboxMessageDelivered = PassthroughSubject<CordialSwiftUIInboxMessageNewInboxMessageDelivered, Never>()
    
    func publishNewInboxMessageDelivered(mcID: String) {
        let newInboxMessageDelivered = CordialSwiftUIInboxMessageNewInboxMessageDelivered(mcID: mcID)
        
        self.newInboxMessageDelivered.send(newInboxMessageDelivered)
    }
    
}
