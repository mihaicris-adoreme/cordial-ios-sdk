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
    
    enum Key: String {
        case mcID = "mcID"
        case html = "html"
    }
    
    init(mcID: String, html: String) {
        self.mcID = mcID
        self.html = html
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.mcID, forKey: Key.mcID.rawValue)
        aCoder.encode(self.html, forKey: Key.html.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let mcID = aDecoder.decodeObject(forKey: Key.mcID.rawValue) as! String
        let html = aDecoder.decodeObject(forKey: Key.html.rawValue) as! String
        
        self.init(mcID: mcID, html: html)
    }
}
