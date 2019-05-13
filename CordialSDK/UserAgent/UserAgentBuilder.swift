//
//  UserAgentBuilder.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 5/13/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation
import UIKit

class UserAgentBuilder {

    func DarwinVersion() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
        return "Darwin/\(dv)"
    }
    
    func CFNetworkVersion() -> String {
        let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
        let version = dictionary?["CFBundleShortVersionString"] as! String
        return "CFNetwork/\(version)"
    }
    
    func deviceVersion() -> String {
        let currentDevice = UIDevice.current
        return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
    }
    
    func deviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func nameAndVersion() -> String {
        let dictionary = Bundle(for: type(of: self)).infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let name = dictionary["CFBundleName"] as! String
        return "\(name)/\(version)"
    }
    
    // "CordialSDK/1.0 iPhone11,2 iOS/12.2 CFNetwork/978.0.7 Darwin/18.5.0"
    func getUserAgent() -> String {
        return "\(self.nameAndVersion()) \(self.deviceName()) \(self.deviceVersion()) \(self.CFNetworkVersion()) \(self.DarwinVersion())"
    }
}
