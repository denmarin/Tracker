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

	var statePublisher: AnyPublisher<State, Never> {
		stateSubject.eraseToAnyPublisher()
	}

	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore
	private let calendar: Calendar
	private let stateSubject: CurrentValueSubject<State, Never>
	private var hasBoundStoreUpdates = false
	private var cancellables = Set<AnyCancellable>()

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore,
		calendar: Calendar = .current
	) {
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.calendar = calendar
		self.stateSubject = CurrentValueSubject<State, Never>(
			State(
				title: String(localized: "statistics.title"),
				emptyMessage: String(localized: "statistics.empty"),
				cards: []
			)
		)
	}

	func viewDidLoad() {
		bindStoreUpdatesIfNeeded()
	}

	private func bindStoreUpdatesIfNeeded() {
		guard !hasBoundStoreUpdates else { return }
		hasBoundStoreUpdates = true

		Publishers.Merge(
			trackerStore.didUpdatePublisher,
			trackerRecordStore.didUpdatePublisher
		)
			.prepend(())
			.sink { [weak self] _ in
				self?.emitState()
			}
			.store(in: &cancellables)
	}

	private func emitState() {
		let trackers = trackerStore.fetchAll().flatMap(\.trackers)
		let records = trackerRecordStore.fetchAll()
		let cards = makeCards(trackers: trackers, records: records)

		stateSubject.send(
			State(
				title: String(localized: "statistics.title"),
				emptyMessage: String(localized: "statistics.empty"),
				cards: cards
			)
		)
	}

	private func makeCards(trackers: [Tracker], records: [TrackerRecord]) -> [StatisticsCardViewData] {
		guard !records.isEmpty else { return [] }

		let habits = trackers.filter { !$0.schedule.isEmpty }
		let bestPeriod = bestPeriod(records: records)
		let perfectDays = perfectDays(habits: habits, records: records)
		let completedCount = records.count
		let averageValue = averageValue(habits: habits, records: records)

		return [
			StatisticsCardViewData(
				value: "\(bestPeriod)",
				title: String(localized: "statistics.bestPeriod")
			),
			StatisticsCardViewData(
				value: "\(perfectDays)",
				title: String(localized: "statistics.perfectDays")
			),
			StatisticsCardViewData(
				value: "\(completedCount)",
				title: String(localized: "statistics.completed")
			),
			StatisticsCardViewData(
				value: "\(averageValue)",
				title: String(localized: "statistics.averageValue")
			)
		]
	}

	private func bestPeriod(records: [TrackerRecord]) -> Int {
		let days = Set(records.map { calendar.startOfDay(for: $0.date) }).sorted()
		guard let firstDay = days.first else { return 0 }

		var best = 1
		var current = 1
		var previousDay = firstDay

		for day in days.dropFirst() {
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

	private func averageValue(habits: [Tracker], records: [TrackerRecord]) -> Int {
		let habitIDs = Set(habits.map(\.id))
		let habitRecords = records.filter { habitIDs.contains($0.trackerId) }
		let uniqueDaysCount = Set(habitRecords.map { calendar.startOfDay(for: $0.date) }).count
		guard uniqueDaysCount > 0 else { return 0 }

		let value = Double(habitRecords.count) / Double(uniqueDaysCount)
		return Int(value.rounded())
	}

	private func perfectDays(habits: [Tracker], records: [TrackerRecord]) -> Int {
		guard !habits.isEmpty else { return 0 }

		let habitIDs = Set(habits.map(\.id))
		var completedHabitsByDay: [Date: Set<UUID>] = [:]

		for record in records where habitIDs.contains(record.trackerId) {
			let day = calendar.startOfDay(for: record.date)
			completedHabitsByDay[day, default: []].insert(record.trackerId)
		}

		return completedHabitsByDay.keys.reduce(into: 0) { result, day in
			let weekday = Weekday.from(day, calendar: calendar)
			let plannedHabitIDs: Set<UUID> = Set(
				habits.compactMap { habit in
					let createdDay = calendar.startOfDay(for: habit.createdAt)
					guard createdDay <= day, habit.schedule.contains(weekday) else { return nil }
					return habit.id
				}
			)

			guard !plannedHabitIDs.isEmpty else { return }

			let completedHabitIDs = completedHabitsByDay[day, default: []]
			if completedHabitIDs == plannedHabitIDs {
				result += 1
			}
		}
	}
}
