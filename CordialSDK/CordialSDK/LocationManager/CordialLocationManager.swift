//
//  CordialLocationManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/13/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation
import os.log

class CordialLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = CordialLocationManager()
    
    var locationManager = CLLocationManager()
    
    var desiredAccuracy: CLLocationAccuracy?
    var distanceFilter: CLLocationDistance?
    var untilTraveled: CLLocationDistance?
    var timeout: TimeInterval?
    
    private override init() {
        super.init()
        
        self.locationManager.delegate = self
    }
    
    private func enableLocationManager(desiredAccuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance, untilTraveled: CLLocationDistance, timeout: TimeInterval) {
        
        self.locationManager.desiredAccuracy = desiredAccuracy
        self.locationManager.distanceFilter = distanceFilter
        
        if CLLocationManager.deferredLocationUpdatesAvailable() {
            self.locationManager.allowDeferredLocationUpdates(untilTraveled: untilTraveled, timeout: timeout)
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { location in
            UserDefaults.standard.set(location.coordinate.latitude, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LATITUDE)
            UserDefaults.standard.set(location.coordinate.longitude, forKey: API.USER_DEFAULTS_KEY_FOR_CURRENT_LOCATION_LONGITUDE)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if let desiredAccuracy = self.desiredAccuracy, let distanceFilter = self.distanceFilter, let untilTraveled = self.untilTraveled, let timeout = self.timeout {
                self.enableLocationManager(desiredAccuracy: desiredAccuracy, distanceFilter: distanceFilter, untilTraveled: untilTraveled, timeout: timeout)
            }
        case .authorizedWhenInUse:
            if let desiredAccuracy = self.desiredAccuracy, let distanceFilter = self.distanceFilter, let untilTraveled = self.untilTraveled, let timeout = self.timeout {
                self.enableLocationManager(desiredAccuracy: desiredAccuracy, distanceFilter: distanceFilter, untilTraveled: untilTraveled, timeout: timeout)
            }
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        
        if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
            os_log("LocationManager fail with error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            if CordialApiConfiguration.shared.osLogManager.isAvailableOsLogLevelForPrint(osLogLevel: .error) {
                os_log("LocationManager deferred updates finish with error: [%{public}@]", log: OSLog.cordialError, type: .error, error.localizedDescription)
            }
        }
    }
    
}
