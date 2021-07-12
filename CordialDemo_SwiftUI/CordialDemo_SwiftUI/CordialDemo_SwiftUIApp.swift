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
        CordialApiConfiguration.shared.pushNotificationDelegate = PushNotificationHandler()
        
        CordialAPI().setContact(primaryKey: "email:www2@ex.ua")
        CordialAPI().registerForPushNotifications(options: [.alert, .sound])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CordialSwiftUIAppDeepLinksPublisher.shared)
        }
    }
}
