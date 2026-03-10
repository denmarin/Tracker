//
//  TrackersFilter.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 08.03.26.
//

import Foundation

enum TrackersFilter: Equatable {
	case completed
	case notCompleted
}

enum TrackersFilterOption: CaseIterable {
	case allTrackers
	case todayTrackers
	case completed
	case notCompleted

	var title: String {
		switch self {
		case .allTrackers:
			return String(localized: "trackers.filter.option.all")
		case .todayTrackers:
			return String(localized: "trackers.filter.option.today")
		case .completed:
			return String(localized: "trackers.filter.option.completed")
		case .notCompleted:
			return String(localized: "trackers.filter.option.notCompleted")
		}
	}

	var persistentFilter: TrackersFilter? {
		switch self {
		case .allTrackers, .todayTrackers:
			return nil
		case .completed:
			return .completed
		case .notCompleted:
			return .notCompleted
		}
	}

	var setsDateToToday: Bool {
		self == .todayTrackers
	}

	func showsCheckmark(selectedFilter: TrackersFilter?) -> Bool {
		switch self {
		case .completed:
			return selectedFilter == .completed
		case .notCompleted:
			return selectedFilter == .notCompleted
		case .allTrackers, .todayTrackers:
			return false
		}
	}
}
