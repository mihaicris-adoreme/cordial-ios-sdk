//
//  JSONStructureExtensions.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

// MARK: Swift Extensions

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

extension Bool: Boxable {
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

extension URL: Boxable {
    var mustacheBox: Box {
        return Box(
            value: self.absoluteString,
            walk: { return "\"\(self)\"" }
        )
    }
}

extension Box: Boxable {
    var mustacheBox: Box {
        return self
    }
}

// MARK: Objective-C Extensions

extension NSNumber: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper? {
        switch CFGetTypeID(self as CFTypeRef) {
            case CFBooleanGetTypeID():
                return ObjCBoxWrapper(JSONStructure().box(boolValue))
            case CFNumberGetTypeID():
                switch CFNumberGetType(self as CFNumber) {
                case .sInt8Type:
                    return ObjCBoxWrapper(JSONStructure().box(Int(int8Value)))
                case .sInt16Type:
                    return ObjCBoxWrapper(JSONStructure().box(Int(int16Value)))
                case .sInt32Type:
                    return ObjCBoxWrapper(JSONStructure().box(Int(int32Value)))
                case .sInt64Type:
                    return ObjCBoxWrapper(JSONStructure().box(Int(int64Value)))
                case .float32Type:
                    return ObjCBoxWrapper(JSONStructure().box(doubleValue))
                case .float64Type:
                    return ObjCBoxWrapper(JSONStructure().box(doubleValue))
                case .charType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .shortType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .intType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .longType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .longLongType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .floatType:
                    return ObjCBoxWrapper(JSONStructure().box(doubleValue))
                case .doubleType:
                    return ObjCBoxWrapper(JSONStructure().box(doubleValue))
                case .cfIndexType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .nsIntegerType:
                    return ObjCBoxWrapper(JSONStructure().box(Int(intValue)))
                case .cgFloatType:
                    return ObjCBoxWrapper(JSONStructure().box(doubleValue))
                default:
                    return nil
                }
            default:
                return nil
        }
    }
}

extension NSString: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper? {
        return ObjCBoxWrapper(JSONStructure().box(self as String))
    }
}

extension NSURL: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper? {
        return ObjCBoxWrapper(JSONStructure().box(self.absoluteString ?? String()))
    }
}

extension NSDictionary: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper? {
        var boxedDictionary: [String: Box] = [:]
        for (key, value) in self {
            if let key = key as? String {
                if let objCBoxable = value as? ObjCBoxable,
                   let box = objCBoxable.mustacheBoxWrapper?.box {
                    boxedDictionary[key] = box
                }
            }
        }
        return ObjCBoxWrapper(JSONStructure().box(boxedDictionary))
    }
}

extension NSArray: ObjCBoxable {
    var mustacheBoxWrapper: ObjCBoxWrapper? {
        var boxedArray: [Box] = []
        for value in self {
            if let objCBoxable = value as? ObjCBoxable,
               let box = objCBoxable.mustacheBoxWrapper?.box {
                boxedArray.append(box)
            }
        }
        return ObjCBoxWrapper(JSONStructure().box(boxedArray))
    }
}
