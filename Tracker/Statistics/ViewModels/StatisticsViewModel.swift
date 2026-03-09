//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation
import Combine

struct StatisticsCardViewData {
	let value: String
	let title: String
}

final class StatisticsViewModel {
	struct State {
		let title: String
		let emptyMessage: String
		let cards: [StatisticsCardViewData]
	}

	private enum L10n {
		static let title = String(localized: "statistics.title")
		static let empty = String(localized: "statistics.empty")
		static let bestPeriod = String(localized: "statistics.bestPeriod")
		static let perfectDays = String(localized: "statistics.perfectDays")
		static let completed = String(localized: "statistics.completed")
		static let averageValue = String(localized: "statistics.averageValue")
	}

	var statePublisher: AnyPublisher<State, Never> {
		stateSubject.eraseToAnyPublisher()
	}

	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore
	private let calendar: Calendar
	private let stateSubject: CurrentValueSubject<State, Never>
	private var cancellables = Set<AnyCancellable>()

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore,
		calendar: Calendar = .current
	) {
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.calendar = calendar
		self.stateSubject = CurrentValueSubject(State(title: L10n.title, emptyMessage: L10n.empty, cards: []))
		observeStoreUpdates()
	}

	func viewDidLoad() {
		emitState()
	}

	private func observeStoreUpdates() {
		Publishers.Merge(
			trackerStore.didUpdatePublisher,
			trackerRecordStore.didUpdatePublisher
		)
			.sink { [weak self] _ in
				self?.emitState()
			}
			.store(in: &cancellables)
	}

	private func emitState() {
		let trackers = trackerStore.fetchAll().flatMap(\.trackers)
		let records = trackerRecordStore.fetchAll()
		stateSubject.send(State(title: L10n.title, emptyMessage: L10n.empty, cards: makeCards(trackers: trackers, records: records)))
	}

	private func makeCards(trackers: [Tracker], records: [TrackerRecord]) -> [StatisticsCardViewData] {
		guard !records.isEmpty else { return [] }

		let habits = trackers.filter { !$0.schedule.isEmpty }
		let habitIDs = Set(habits.map(\.id))
		let completionDays = Set(records.map { normalizedDay($0.date) }).sorted()
		let habitRecords = records.filter { habitIDs.contains($0.trackerId) }
		let habitCompletionDays = Set(habitRecords.map { normalizedDay($0.date) })
		let completedHabitsByDay = completedTrackerIDsByDay(records: habitRecords)

		let bestPeriod = bestPeriod(from: completionDays)
		let perfectDays = completedHabitsByDay.reduce(into: 0) { result, item in
			let plannedHabitIDs = plannedHabitIDs(on: item.key, habits: habits)
			guard !plannedHabitIDs.isEmpty else { return }
			if item.value == plannedHabitIDs {
				result += 1
			}
		}
		let completedCount = records.count
		let averageValue = habitCompletionDays.isEmpty
		? 0
		: Int((Double(habitRecords.count) / Double(habitCompletionDays.count)).rounded())

		return [
			card(value: bestPeriod, title: L10n.bestPeriod),
			card(value: perfectDays, title: L10n.perfectDays),
			card(value: completedCount, title: L10n.completed),
			card(value: averageValue, title: L10n.averageValue)
		]
	}

	private func card(value: Int, title: String) -> StatisticsCardViewData {
		StatisticsCardViewData(value: "\(value)", title: title)
	}

	private func normalizedDay(_ date: Date) -> Date {
		calendar.startOfDay(for: date)
	}

	private func completedTrackerIDsByDay(records: [TrackerRecord]) -> [Date: Set<UUID>] {
		records.reduce(into: [Date: Set<UUID>]()) { result, record in
			result[normalizedDay(record.date), default: []].insert(record.trackerId)
		}
	}

	private func bestPeriod(from sortedDays: [Date]) -> Int {
		guard let firstDay = sortedDays.first else { return 0 }

		var best = 1
		var current = 1
		var previousDay = firstDay

		for day in sortedDays.dropFirst() {
			guard let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: previousDay) else {
				previousDay = day
				current = 1
				continue
			}

			if calendar.isDate(day, inSameDayAs: expectedNextDay) {
				current += 1
			} else {
				current = 1
			}

			best = max(best, current)
			previousDay = day
		}

		return best
	}

	private func plannedHabitIDs(on day: Date, habits: [Tracker]) -> Set<UUID> {
		let weekday = Weekday.from(day, calendar: calendar)
		return Set(habits.compactMap { habit in
			guard normalizedDay(habit.createdAt) <= day, habit.schedule.contains(weekday) else { return nil }
			return habit.id
		})
	}
}
