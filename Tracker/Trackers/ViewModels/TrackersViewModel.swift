//
//  TrackersViewModel.swift
//  Tracker
//

import Foundation

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

	var onStateChanged: ((State) -> Void)?
	var onRequestTrackerCreation: (() -> Void)?
	var onAlert: ((Alert) -> Void)?

	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore
	private let trackerCategoryStore: TrackerCategoryStore
	private let calendar: Calendar

	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
	private var selectedDate: Date
	private var hasBoundStoreUpdates = false

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore,
		trackerCategoryStore: TrackerCategoryStore,
		initialDate: Date = Date(),
		calendar: Calendar = .current
	) {
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.trackerCategoryStore = trackerCategoryStore
		self.calendar = calendar
		self.selectedDate = calendar.startOfDay(for: initialDate)
	}

	func viewDidLoad() {
		bindStoreUpdatesIfNeeded()
		reloadDataFromStores()
	}

	func didTapCreateTracker() {
		onRequestTrackerCreation?()
	}

	func didChangeSelectedDate(_ date: Date) {
		let normalizedDate = calendar.startOfDay(for: date)
		guard normalizedDate != selectedDate else { return }
		selectedDate = normalizedDate
		emitState()
	}

	func didTapToggleCompletion(for trackerID: UUID) {
		if isFutureSelectedDate() {
			onAlert?(.futureDateNotAllowed)
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
			onAlert?(.operationFailed(message: "Не удалось обновить отметку трекера."))
		}
	}

	func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
		do {
			try trackerStore.add(tracker, toCategoryWithTitle: title)
		} catch {
			assertionFailure("Failed to add tracker: \(error)")
			onAlert?(.operationFailed(message: "Не удалось создать трекер."))
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

		trackerStore.onDidUpdate = { [weak self] in
			self?.reloadDataFromStores()
		}
		trackerRecordStore.onDidUpdate = { [weak self] in
			self?.reloadDataFromStores()
		}
	}

	private func reloadDataFromStores() {
		categories = trackerStore.fetchAll()
		completedTrackers = trackerRecordStore.fetchAll()
		emitState()
	}

	private func emitState() {
		let sections = makeFilteredSections(for: selectedDate)
		onStateChanged?(State(sections: sections, selectedDate: selectedDate))
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
		if selectedDay == createdDay {
			return true
		}
		if selectedDay > createdDay {
			let wasCompletedOnCreationDay = completedTrackers.contains(
				TrackerRecord(trackerId: tracker.id, date: createdDay)
			)
			return !wasCompletedOnCreationDay
		}
		return false
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
