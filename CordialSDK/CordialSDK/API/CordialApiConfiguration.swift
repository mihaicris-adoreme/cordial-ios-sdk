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
    let initInAppMessageProcess = InAppMessageProcess.shared
    
    @objc public var qtyCachedEventQueue = 1000
    
    var accountKey = String()
    var channelKey = String()
    var baseURL = String()
    
    let cordialSwizzler = CordialSwizzler()
    let cordialPushNotification = CordialPushNotification()
    @objc public let osLogManager = CordialOSLogManager()
    
    @objc public var continueRestorationHandler: CordialContinueRestorationDelegate?
    @objc public var openOptionsHandler: CordialOpenOptionsDelegate?
    @objc public var pushNotificationHandler: CordialPushNotificationDelegate?
    
    private override init(){}
    
    @objc public func initialize(accountKey: String, channelKey: String) {
        self.accountKey = accountKey
        self.channelKey = channelKey
        self.baseURL = "https://events-stream-svc.cordial-core.mobile-sdk-1-4.cordialdev.com/"
        
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
