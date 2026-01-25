//
//  Tracker.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//

import UIKit
import Foundation

struct Tracker: Identifiable, Hashable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: Set<Weekday>
    let createdAt: Date

    init(id: UUID = UUID(), title: String, emoji: String, color: UIColor, schedule: Set<Weekday> = [], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
        self.createdAt = createdAt
    }

    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
