//
//  InAppMessageData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageData: NSObject, NSCoding {
    
    let mcID: String
    let html: String
    let type: InAppMessageType
    let top: Int
    let right: Int
    let bottom: Int
    let left: Int
    let dismissBannerEventName: String?
    
    enum Key: String {
        case mcID = "mcID"
        case html = "html"
        case type = "type"
        case top = "top"
        case right = "right"
        case bottom = "bottom"
        case left = "left"
        case dismissBannerEventName = "dismissBannerEventName"
    }
    
    init(mcID: String, html: String, type: InAppMessageType, top: Int, right: Int, bottom: Int, left: Int, dismissBannerEventName: String?) {
        self.mcID = mcID
        self.html = html
        self.type = type
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.dismissBannerEventName = dismissBannerEventName
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.html, forKey: Key.html.rawValue)
        aCoder.encode(self.type.rawValue, forKey: Key.type.rawValue)
        aCoder.encode(self.top, forKey: Key.top.rawValue)
        aCoder.encode(self.right, forKey: Key.right.rawValue)
        aCoder.encode(self.bottom, forKey: Key.bottom.rawValue)
        aCoder.encode(self.left, forKey: Key.left.rawValue)
        aCoder.encode(self.left, forKey: Key.dismissBannerEventName.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String
        let html = aDecoder.decodeObject(forKey: Key.html.rawValue) as! String
        let type = InAppMessageType(rawValue: aDecoder.decodeObject(forKey: Key.type.rawValue) as! String)!
        let top = Int(aDecoder.decodeInt32(forKey: Key.top.rawValue))
        let right = Int(aDecoder.decodeInt32(forKey: Key.right.rawValue))
        let bottom = Int(aDecoder.decodeInt32(forKey: Key.bottom.rawValue))
        let left = Int(aDecoder.decodeInt32(forKey: Key.left.rawValue))
        let dismissBannerEventName = aDecoder.decodeObject(forKey: Key.dismissBannerEventName.rawValue) as? String
        
        self.init(mcID: mcID, html: html, type: type, top: top, right: right, bottom: bottom, left: left, dismissBannerEventName: dismissBannerEventName)
    }
}
