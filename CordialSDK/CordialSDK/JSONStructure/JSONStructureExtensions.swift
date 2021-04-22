//
//  JSONStructureExtensions.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

extension Int: Boxable {
    var mustacheBox: Box {
        return Box(
            value: self,
            walk: { return "\(self)" }
        )
    }
}

extension Double: Boxable {
    var mustacheBox: Box {
        return Box(
            value: self,
            walk: { return "\(self)" }
        )
    }
}

extension String: Boxable {
    var mustacheBox: Box {
        return Box(
            value: self,
            walk: { return "\"\(self)\"" }
        )
    }
}

extension Bool: Boxable {
    var mustacheBox: Box {
        return Box(
            value: self,
            walk: { return "\(self)" }
        )
    }
}

extension Box: Boxable {
    var mustacheBox: Box {
        return self
    }
}

extension NSNumber: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper {
        let objCType = self.objCType
        let str = String(cString:objCType)
        switch str {
        case "c", "i", "s", "l", "q", "C", "I", "S", "L", "Q":
            return ObjCBoxWrapper(JSONStructure().box(Int(int64Value)))
        case "f", "d":
            return ObjCBoxWrapper(JSONStructure().box(doubleValue))
        case "B":
            return ObjCBoxWrapper(JSONStructure().box(boolValue))
        default:
            fatalError("Not implemented yet")
        }
    }
}

extension NSString: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper {
        return ObjCBoxWrapper(JSONStructure().box(self as String))
    }
}

extension NSDictionary: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper {
        var boxedDictionary: [String: Box] = [:]
        for (key, value) in self {
            if let key = key as? String {
                if let objCBoxable = value as? ObjCBoxable {
                    boxedDictionary[key] = objCBoxable.mustacheBoxWrapper.box
                }
            }
        }
        return ObjCBoxWrapper(JSONStructure().box(boxedDictionary))
    }
}

extension NSArray: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper {
        var boxedArray: [Box] = []
        for value in self {
            if let objCBoxable = value as? ObjCBoxable {
                boxedArray.append(objCBoxable.mustacheBoxWrapper.box)
            }
        }
        return ObjCBoxWrapper(JSONStructure().box(boxedArray))
    }
}
