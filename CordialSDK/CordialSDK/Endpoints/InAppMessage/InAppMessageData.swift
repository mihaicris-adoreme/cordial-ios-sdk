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
    let displayType: InAppMessageDisplayType
    let top: Int
    let right: Int
    let bottom: Int
    let left: Int
    let expirationTime: Date?
    
    enum Key: String {
        case mcID = "mcID"
        case html = "html"
        case type = "type"
        case displayType = "displayType"
        case top = "top"
        case right = "right"
        case bottom = "bottom"
        case left = "left"
        case expirationTime = "expirationTime"
    }
    
    init(mcID: String, html: String, type: InAppMessageType, displayType: InAppMessageDisplayType, top: Int, right: Int, bottom: Int, left: Int, expirationTime: Date?) {
        self.mcID = mcID
        self.html = html
        self.type = type
        self.displayType = displayType
        self.top = top
        self.right = right
        self.bottom = bottom
        self.left = left
        self.expirationTime = expirationTime
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.html, forKey: Key.html.rawValue)
        aCoder.encode(self.type.rawValue, forKey: Key.type.rawValue)
        aCoder.encode(self.displayType.rawValue, forKey: Key.displayType.rawValue)
        aCoder.encode(self.top, forKey: Key.top.rawValue)
        aCoder.encode(self.right, forKey: Key.right.rawValue)
        aCoder.encode(self.bottom, forKey: Key.bottom.rawValue)
        aCoder.encode(self.left, forKey: Key.left.rawValue)
        aCoder.encode(self.expirationTime, forKey: Key.expirationTime.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String
        let html = aDecoder.decodeObject(forKey: Key.html.rawValue) as! String
        let type = InAppMessageType(rawValue: aDecoder.decodeObject(forKey: Key.type.rawValue) as! String)!
        let displayType = InAppMessageDisplayType(rawValue: aDecoder.decodeObject(forKey: Key.displayType.rawValue) as! String)!
        let top = Int(aDecoder.decodeInt32(forKey: Key.top.rawValue))
        let right = Int(aDecoder.decodeInt32(forKey: Key.right.rawValue))
        let bottom = Int(aDecoder.decodeInt32(forKey: Key.bottom.rawValue))
        let left = Int(aDecoder.decodeInt32(forKey: Key.left.rawValue))
        let expirationTime = aDecoder.decodeObject(forKey: Key.expirationTime.rawValue) as? Date
        
        self.init(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
    }
}
