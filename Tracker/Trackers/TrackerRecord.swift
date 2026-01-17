//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//

import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date

    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = Calendar.current.startOfDay(for: date)
    }
}
