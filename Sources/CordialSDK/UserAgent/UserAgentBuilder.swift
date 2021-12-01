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
        return "iOS/\(currentDevice.systemVersion)"
    }
    
    func deviceName() -> String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func sdkNameAndVersion() -> String {
        return "CordialSDK/\(CordialApiConfiguration.shared.sdkVersion)"
    }
    
    func appVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return "App/\(version)"
    }
    
    // "CordialSDK/1.0 iPhone11,2 iOS/12.2 CFNetwork/978.0.7 Darwin/18.5.0 App/1.0"
    func getUserAgent() -> String {
        return "\(self.sdkNameAndVersion()) \(self.deviceName()) \(self.deviceVersion()) \(self.CFNetworkVersion()) \(self.DarwinVersion()) \(self.appVersion())"
    }
}
