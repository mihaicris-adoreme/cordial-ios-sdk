//
//  JSONStructure.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 21.04.2021.
//  Copyright © 2021 cordial.io. All rights reserved.
//

import Foundation

// =============================================================================
// Boxing Swift type and ObjC class (array of values and dictionaries of values)
// The Box
struct Box {
    let value: Any
    let walk: () -> ()
}

// =============================================================================
// Boxing simple Swift types
// Boxable object can produce a Box
protocol Boxable {
    var mustacheBox: Box { get }
}

// box(Boxable) -> Box
func box<T: Boxable>(_ boxable: T) -> Box {
    return boxable.mustacheBox
}

// =============================================================================
// Boxing Swift arrays
// box([Boxable]) -> Box
func box<S: Sequence>(_ sequence: S) -> Box where S.Iterator.Element: Boxable {
    return Box(
        value: sequence.map { $0.mustacheBox },
        walk: {
            print("[")
            for boxable in sequence {
                boxable.mustacheBox.walk()
                print(",")
            }
            print("]")
        }
    )
}

// =============================================================================
// Boxing Swift dictionaries
// box([String: Boxable]) -> Box
func box<T: Boxable>(_ dictionary: [String: T]) -> Box {
    var boxedDictionary: [String: Box] = [:]
    for (key, value) in dictionary {
        boxedDictionary[key] = box(value)
    }
    return Box(
        value: boxedDictionary,
        walk: {
            print("[")
            for (key, boxable) in dictionary {
                print("\(key):")
                boxable.mustacheBox.walk()
                print(",")
            }
            print("]")
        }
    )
}

// =============================================================================
// Boxing Objctive-C objects
// The Boxable protocol can not be used by Objc classes, because the Box struct
// is not compatible with ObjC. So let's define another protocol.
@objc protocol ObjCBoxable {
    // Can not return a Box, because Box is not compatible with ObjC.
    // So let's return an ObjC object which wraps a Box.
    var mustacheBoxWrapper: ObjCBoxWrapper { get }
}

// The ObjC object which wraps a Box (see ObjCBoxable)
class ObjCBoxWrapper: NSObject {
    let box: Box
    init(_ box: Box) {
        self.box = box
    }
}

// box(ObjCBoxable) -> Box
func box(_ boxable: ObjCBoxable) -> Box {
    return boxable.mustacheBoxWrapper.box
}
