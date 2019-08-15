//
//  CordialApiConfiguration.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 4/8/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation

@objc public class CordialApiConfiguration: NSObject {
    
    @objc public static let shared = CordialApiConfiguration()
    
    let initReachabilityManagerSingleton = ReachabilityManager.shared
    let initReachabilitySenderSingleton = ReachabilitySender.shared
    let initNotificationManager = NotificationManager.shared
    
    @objc public var qtyCachedEventQueue = 1000
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    let cordialSwizzler = CordialSwizzler()
    
    @objc public var continueRestorationHandler: CordialContinueRestorationDelegate?
    @objc public var openOptionsHandler: CordialOpenOptionsDelegate?
    @objc public var pushNotificationHandler: CordialPushNotificationDelegate?
    
    let cordialPushNotification = CordialPushNotification()
    
    private override init(){}
    
    @objc public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.cordial-core.ticket-5667.cordialdev.com/"
        
//        CoreDataManager.shared.deleteAllCoreData()
        
        InternalCordialAPI().prepareDeviceIdentifier()
        
    }
    
    @objc public func initializeLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        CordialLocationManager.shared.desiredAccuracy = desiredAccuracy
        CordialLocationManager.shared.distanceFilter = distanceFilter
        CordialLocationManager.shared.untilTraveled = untilTraveled
        CordialLocationManager.shared.timeout = timeout
        
        CordialLocationManager.shared.locationManager.requestWhenInUseAuthorization()
    }
    
}
