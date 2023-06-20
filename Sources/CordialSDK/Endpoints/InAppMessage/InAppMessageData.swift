//
//  InAppMessageData.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 7/4/19.
//  Copyright © 2019 cordial.io. All rights reserved.
//

import Foundation

class InAppMessageData: NSObject, NSCoding, NSSecureCoding {
    
    static var supportsSecureCoding = true
    
    let mcID: String
    let html: String
    let type: InAppMessageType
    let displayType: InAppMessageDisplayType
    let top: Int
    let right: Int
    let bottom: Int
    let left: Int
    let expirationTime: Date?
    
    var isError = false
    
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
    
    func encode(with coder: NSCoder) {
        coder.encode(self.mcID, forKey: Key.mcID.rawValue)
        coder.encode(self.html, forKey: Key.html.rawValue)
        coder.encode(self.type.rawValue, forKey: Key.type.rawValue)
        coder.encode(self.displayType.rawValue, forKey: Key.displayType.rawValue)
        coder.encode(self.top, forKey: Key.top.rawValue)
        coder.encode(self.right, forKey: Key.right.rawValue)
        coder.encode(self.bottom, forKey: Key.bottom.rawValue)
        coder.encode(self.left, forKey: Key.left.rawValue)
        coder.encode(self.expirationTime, forKey: Key.expirationTime.rawValue)
    }
    
    required convenience init?(coder: NSCoder) {
        if let mcID = coder.decodeObject(forKey: Key.mcID.rawValue) as? String,
           let html = coder.decodeObject(forKey: Key.html.rawValue) as? String,
           let InAppMessageTypeString = coder.decodeObject(forKey: Key.type.rawValue) as? String,
           let type = InAppMessageType(rawValue: InAppMessageTypeString),
           let displayTypeString = coder.decodeObject(forKey: Key.displayType.rawValue) as? String,
           let displayType = InAppMessageDisplayType(rawValue: displayTypeString) {
            
            let top = Int(coder.decodeInt32(forKey: Key.top.rawValue))
            let right = Int(coder.decodeInt32(forKey: Key.right.rawValue))
            let bottom = Int(coder.decodeInt32(forKey: Key.bottom.rawValue))
            let left = Int(coder.decodeInt32(forKey: Key.left.rawValue))
            let expirationTime = coder.decodeObject(forKey: Key.expirationTime.rawValue) as? Date
            
            self.init(mcID: mcID, html: html, type: type, displayType: displayType, top: top, right: right, bottom: bottom, left: left, expirationTime: expirationTime)
        } else {
            self.init(mcID: String(), html: String(), type: InAppMessageType.modal, displayType: InAppMessageDisplayType.displayImmediately, top: 0, right: 0, bottom: 0, left: 0, expirationTime: nil)
            
            self.isError = true
        }
    }
}
