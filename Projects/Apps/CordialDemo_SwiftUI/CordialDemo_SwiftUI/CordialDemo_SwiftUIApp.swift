//
//  CordialDemo_SwiftUIApp.swift
//  CordialDemo_SwiftUI
//
//  Created by Yan Malinovsky on 09.06.2021.
//

import SwiftUI
import CoreLocation
import CordialSDK

@main
struct CordialDemo_SwiftUIApp: App {
    
    init() {
//        CordialApiConfiguration.shared.initialize(accountKey: "qc-all-channels-cID-pk", channelKey: "push")
        CordialApiConfiguration.shared.initialize(accountKey: "stgtaras", channelKey: "sdk")
        
        CordialApiConfiguration.shared.initializeLocationManager(desiredAccuracy: kCLLocationAccuracyBest, distanceFilter: kCLDistanceFilterNone, untilTraveled: CLLocationDistanceMax, timeout: CLTimeIntervalMax)
        CordialApiConfiguration.shared.qtyCachedEventQueue = 100
        CordialApiConfiguration.shared.eventsBulkSize = 3
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 15
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.all)
        CordialApiConfiguration.shared.vanityDomains = ["e.a45.clients.cordialdev.com", "events-handling-svc.cordial.io"]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppHandler.shared)
                .environmentObject(CordialSwiftUIPushNotificationPublisher.shared)
                .environmentObject(CordialSwiftUIDeepLinksPublisher.shared)
                .environmentObject(CordialSwiftUIInboxMessagePublisher.shared)
                .environmentObject(CordialSwiftUIInAppMessagePublisher.shared)
        }
    }
}
