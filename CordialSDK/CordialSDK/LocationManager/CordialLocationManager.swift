//
//  CordialLocationManager.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 6/13/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import CoreLocation

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
        } else {
            print("Device not supporte deferredLocationUpdates")
        }
        
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.description)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if let desiredAccuracy = self.desiredAccuracy, let distanceFilter = self.distanceFilter, let untilTraveled = self.untilTraveled, let timeout = self.timeout {
                self.enableLocationManager(desiredAccuracy: desiredAccuracy, distanceFilter: distanceFilter, untilTraveled: untilTraveled, timeout: timeout)
            }
            print("Location status is OK always.")
        case .authorizedWhenInUse:
            if let desiredAccuracy = self.desiredAccuracy, let distanceFilter = self.distanceFilter, let untilTraveled = self.untilTraveled, let timeout = self.timeout {
                self.enableLocationManager(desiredAccuracy: desiredAccuracy, distanceFilter: distanceFilter, untilTraveled: untilTraveled, timeout: timeout)
            }
            print("Location status is OK when app in use.")
        default: break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        print("Fail with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        if let error = error {
            print("Deferred updates finish with error: \(error)")
        }
    }
    
}
