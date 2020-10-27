//
//  Throttler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class Throttler {

    private var workItem: DispatchWorkItem 
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval
    private let flags: DispatchWorkItemFlags

    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main, flags: DispatchWorkItemFlags = []) {
        self.minimumDelay = minimumDelay
        self.queue = queue
        self.flags = flags
        self.workItem = DispatchWorkItem(qos: .unspecified, flags: flags, block: {})
    }

    func throttle(_ block: @escaping () -> Void) {
        // Cancel any existing work item if it has not yet executed
        self.workItem.cancel()

        // Re-assign workItem with the new block task, resetting the previousRun time when it executes
        self.workItem = DispatchWorkItem(qos: DispatchQoS.unspecified, flags: flags) { [weak self] in
            self?.previousRun = Date()
            block()
        }

        // If the time since the previous run is more than the required minimum delay
        // => execute the workItem immediately
        // else
        // => delay the workItem execution by the minimum delay time
        let delay = self.previousRun.timeIntervalSinceNow > self.minimumDelay ? 0 : self.minimumDelay
        self.queue.asyncAfter(deadline: .now() + Double(delay), execute: self.workItem)
    }
}
