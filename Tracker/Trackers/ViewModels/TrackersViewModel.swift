//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation
import Combine

struct TrackerItemViewData {
	let tracker: Tracker
	let completedCount: Int
	let isCompletedOnSelectedDate: Bool
}

struct TrackerCategorySectionViewData {
	let title: String
	let items: [TrackerItemViewData]
}

final class TrackersViewModel {
	struct State {
		let sections: [TrackerCategorySectionViewData]
		let selectedDate: Date

		var isEmpty: Bool {
			sections.isEmpty
		}
	}

	enum Alert {
		case futureDateNotAllowed
		case operationFailed(message: String)

		var title: String? {
			switch self {
			case .futureDateNotAllowed:
				return "Нельзя отметить будущее"
			case .operationFailed:
				return nil
			}
		}

		var message: String {
			switch self {
			case .futureDateNotAllowed:
				return "Выберите сегодняшнюю или прошедшую дату."
			case .operationFailed(let message):
				return message
			}
		}
	}

	var statePublisher: AnyPublisher<State, Never> {
		stateSubject.eraseToAnyPublisher()
	}
	var requestTrackerCreationPublisher: AnyPublisher<Void, Never> {
		requestTrackerCreationSubject.eraseToAnyPublisher()
	}
	var alertPublisher: AnyPublisher<Alert, Never> {
		alertSubject.eraseToAnyPublisher()
	}

	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore
	private let trackerCategoryStore: TrackerCategoryStore
	private let calendar: Calendar

	private let stateSubject: CurrentValueSubject<State, Never>
	private let requestTrackerCreationSubject = PassthroughSubject<Void, Never>()
	private let alertSubject = PassthroughSubject<Alert, Never>()
	private let selectedDateSubject: CurrentValueSubject<Date, Never>

	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
	private var selectedDate: Date
	private var hasBoundStoreUpdates = false
	private var cancellables = Set<AnyCancellable>()

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore,
		trackerCategoryStore: TrackerCategoryStore,
		initialDate: Date = Date(),
		calendar: Calendar = .current
	) {
		let normalizedInitialDate = calendar.startOfDay(for: initialDate)
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.trackerCategoryStore = trackerCategoryStore
		self.calendar = calendar
		self.selectedDate = normalizedInitialDate
		self.selectedDateSubject = CurrentValueSubject(normalizedInitialDate)
		self.stateSubject = CurrentValueSubject(
			State(sections: [], selectedDate: normalizedInitialDate)
		)
	}

	func viewDidLoad() {
		bindStoreUpdatesIfNeeded()
		reloadDataFromStores()
	}

	func didTapCreateTracker() {
		requestTrackerCreationSubject.send(())
	}

	func didChangeSelectedDate(_ date: Date) {
		let normalizedDate = calendar.startOfDay(for: date)
		guard normalizedDate != selectedDate else { return }
		selectedDateSubject.send(normalizedDate)
	}

	func didTapToggleCompletion(for trackerID: UUID) {
		if isFutureSelectedDate() {
			alertSubject.send(.futureDateNotAllowed)
			return
		}

		let record = TrackerRecord(trackerId: trackerID, date: selectedDate)
		do {
			if completedTrackers.contains(record) {
				try trackerRecordStore.delete(record)
			} else {
				try trackerRecordStore.add(record)
			}
		} catch {
			assertionFailure("Failed to update tracker completion: \(error)")
			alertSubject.send(.operationFailed(message: "Не удалось обновить отметку трекера."))
		}
	}

	func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
		do {
			try trackerStore.add(tracker, toCategoryWithTitle: title)
		} catch {
			assertionFailure("Failed to add tracker: \(error)")
			alertSubject.send(.operationFailed(message: "Не удалось создать трекер."))
		}
	}

	func makeTrackerTypeSelectionViewModel(
		onCreate: @escaping (Tracker, String) -> Void
	) -> TrackerTypeSelectionViewModel {
		TrackerTypeSelectionViewModel(
			trackerCategoryStore: trackerCategoryStore,
			onCreate: onCreate
		)
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
			self?.reloadDataFromStores()
		}
		.store(in: &cancellables)

		selectedDateSubject
			.removeDuplicates()
			.sink { [weak self] selectedDate in
				guard let self else { return }
				self.selectedDate = selectedDate
				self.emitState()
			}
			.store(in: &cancellables)
	}

	private func reloadDataFromStores() {
		categories = trackerStore.fetchAll()
		completedTrackers = trackerRecordStore.fetchAll()
		emitState()
	}

	private func emitState() {
		let sections = makeFilteredSections(for: selectedDate)
		stateSubject.send(State(sections: sections, selectedDate: selectedDate))
	}

	private func makeFilteredSections(for date: Date) -> [TrackerCategorySectionViewData] {
		let weekday = Weekday.from(date)

		return categories.compactMap { category in
			let items = category.trackers.compactMap { tracker -> TrackerItemViewData? in
				guard shouldDisplayTracker(tracker, on: date, weekday: weekday) else {
					return nil
				}

				return TrackerItemViewData(
					tracker: tracker,
					completedCount: completedCount(for: tracker.id),
					isCompletedOnSelectedDate: isTrackerCompleted(trackerID: tracker.id, on: date)
				)
			}

			guard !items.isEmpty else { return nil }
			return TrackerCategorySectionViewData(title: category.title, items: items)
		}
	}

	private func shouldDisplayTracker(_ tracker: Tracker, on selectedDay: Date, weekday: Weekday) -> Bool {
		if !tracker.schedule.isEmpty {
			return tracker.schedule.contains(weekday)
		}

		let createdDay = calendar.startOfDay(for: tracker.createdAt)
		guard selectedDay >= createdDay else { return false }

		// Нерегулярный трекер отображается до первой отметки.
		// В день первой отметки он остается видимым, чтобы пользователь мог снять отметку.
		let hasCompletionBeforeSelectedDay = completedTrackers.contains { record in
			record.trackerId == tracker.id && record.date < selectedDay
		}
		return !hasCompletionBeforeSelectedDay
	}

	private func completedCount(for trackerID: UUID) -> Int {
		completedTrackers.filter { $0.trackerId == trackerID }.count
	}

	private func isTrackerCompleted(trackerID: UUID, on date: Date) -> Bool {
		completedTrackers.contains(TrackerRecord(trackerId: trackerID, date: date))
	}

	private func isFutureSelectedDate() -> Bool {
		let today = calendar.startOfDay(for: Date())
		return selectedDate > today
	}
}
