//
//  Weekday.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//


import Foundation

enum Weekday: Int, CaseIterable, Hashable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    static func from(_ date: Date, calendar: Calendar = .current) -> Weekday {
        let weekdayIndex = calendar.component(.weekday, from: date)
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }

    static let ordered: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

	var fullName: String {
		switch self {
		case .monday: String(localized: "weekday.monday.full")
		case .tuesday: String(localized: "weekday.tuesday.full")
		case .wednesday: String(localized: "weekday.wednesday.full")
		case .thursday: String(localized: "weekday.thursday.full")
		case .friday: String(localized: "weekday.friday.full")
		case .saturday: String(localized: "weekday.saturday.full")
		case .sunday: String(localized: "weekday.sunday.full")
		}
	}

    var shortName: String {
        switch self {
        case .monday: String(localized: "weekday.monday.short")
        case .tuesday: String(localized: "weekday.tuesday.short")
        case .wednesday: String(localized: "weekday.wednesday.short")
        case .thursday: String(localized: "weekday.thursday.short")
        case .friday: String(localized: "weekday.friday.short")
        case .saturday: String(localized: "weekday.saturday.short")
        case .sunday: String(localized: "weekday.sunday.short")
        }
    }
}
