//
//  Weekday.swift
//  Tracker
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
		case .monday: "Понедельник"
		case .tuesday: "Вторник"
		case .wednesday: "Среда"
		case .thursday: "Четверг"
		case .friday: "Пятница"
		case .saturday: "Суббота"
		case .sunday: "Воскресенье"
		}
	}

    var shortName: String {
        switch self {
        case .monday: "Пн"
        case .tuesday: "Вт"
        case .wednesday: "Ср"
        case .thursday: "Чт"
        case .friday: "Пт"
        case .saturday: "Сб"
        case .sunday: "Вс"
        }
    }
}
