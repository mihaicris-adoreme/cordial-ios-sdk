//
//  Throttler.swift
//  CordialSDK
//
//  Created by Yan Malinovsky on 28.04.2020.
//  Copyright © 2020 cordial.io. All rights reserved.
//

import Foundation

class Throttler {

    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousRun: Date = Date.distantPast
    private let queue: DispatchQueue
    private let minimumDelay: TimeInterval

    init(minimumDelay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.minimumDelay = minimumDelay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        // Cancel any existing work item if it has not yet executed
        self.workItem.cancel()

        // Re-assign workItem with the new block task, resetting the previousRun time when it executes
        self.workItem = DispatchWorkItem() { [weak self] in
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
