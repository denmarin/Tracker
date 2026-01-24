//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//

import Foundation

struct TrackerCategory: Hashable {
    let title: String
    let trackers: [Tracker]

    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}

