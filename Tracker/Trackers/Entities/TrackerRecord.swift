//
//  TrackerRecord.swift
//  Tracker
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
