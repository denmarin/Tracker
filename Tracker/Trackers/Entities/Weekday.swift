//
//  Weekday.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//

import Foundation

/// День недели для расписания трекера.
/// Используется в `Tracker.schedule` как множество уникальных дней.
enum Weekday: Int, CaseIterable, Hashable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    /// Создать день недели по дате с учётом календаря.
    /// В `Calendar`, Sunday = 1 ... Saturday = 7.
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

    /// Порядок дней недели для отображения (Пн..Вс)
    static let ordered: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    /// Полное имя дня недели на русском
    var fullName: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    /// Короткое имя дня недели на русском
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
