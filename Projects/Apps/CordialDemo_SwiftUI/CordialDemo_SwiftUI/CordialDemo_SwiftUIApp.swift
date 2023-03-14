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
        // Staging credentials
        let eventsStreamURL = "https://events-stream-svc.stg.cordialdev.com/"
        let messageHubURL = "https://message-hub-svc.stg.cordialdev.com/"
        let accountKey = "stgtaras"
        let channelKey = "sdk"
        
        CordialApiConfiguration.shared.initialize(accountKey: accountKey, channelKey: channelKey, eventsStreamURL: eventsStreamURL, messageHubURL: messageHubURL)
        
        CordialApiConfiguration.shared.initializeLocationManager(desiredAccuracy: kCLLocationAccuracyBest, distanceFilter: kCLDistanceFilterNone, untilTraveled: CLLocationDistanceMax, timeout: CLTimeIntervalMax)
        CordialApiConfiguration.shared.qtyCachedEventQueue = 100
        CordialApiConfiguration.shared.eventsBulkSize = 3
        CordialApiConfiguration.shared.eventsBulkUploadInterval = 15
        CordialApiConfiguration.shared.osLogManager.setOSLogLevel(.all)
        
        CordialApiConfiguration.shared.notificationSettingsConfiguration = .APP
        
        CordialApiConfiguration.shared.setNotificationSettings([
            PushNotificationSettings(key: "discounts", name: "Discounts", initState: true),
            PushNotificationSettings(key: "new-arrivals", name: "New Arrivals", initState: false),
            PushNotificationSettings(key: "top-products", name: "Top Products", initState: true)
        ])
        
        CordialApiConfiguration.shared.vanityDomains = ["e.a45.clients.cordialdev.com", "events-handling-svc.cordial.io"]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppHandler.shared)
                .environmentObject(CordialSwiftUIPushNotificationPublisher.shared)
                .environmentObject(CordialSwiftUIPushNotificationSettingsPublisher.shared)
                .environmentObject(CordialSwiftUIDeepLinksPublisher.shared)
                .environmentObject(CordialSwiftUIInboxMessagePublisher.shared)
                .environmentObject(CordialSwiftUIInAppMessagePublisher.shared)
        }
    }
}
