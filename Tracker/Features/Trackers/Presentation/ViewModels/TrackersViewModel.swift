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
	enum EmptyState {
		case noTrackers
		case noSearchResults
	}

	struct State {
		let sections: [TrackerCategorySectionViewData]
		let selectedDate: Date
		let emptyState: EmptyState?
		let isFilterButtonHidden: Bool
		let selectedFilter: TrackersFilter?

		var isEmpty: Bool {
			emptyState != nil
		}
	}

	enum Alert {
		case futureDateNotAllowed
		case operationFailed(message: String)

		var title: String? {
			switch self {
			case .futureDateNotAllowed:
				return String(localized: "tracker.alert.futureDate.title")
			case .operationFailed:
				return nil
			}
		}

		var message: String {
			switch self {
			case .futureDateNotAllowed:
				return String(localized: "tracker.alert.futureDate.message")
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
	private let searchQuerySubject: CurrentValueSubject<String, Never>

	private var categories: [TrackerCategory] = []
	private var completedTrackers: [TrackerRecord] = []
	private var selectedDate: Date
	private var searchQuery = ""
	private var selectedFilter: TrackersFilter?
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
		self.searchQuerySubject = CurrentValueSubject("")
		self.stateSubject = CurrentValueSubject(
			State(
				sections: [],
				selectedDate: normalizedInitialDate,
				emptyState: .noTrackers,
				isFilterButtonHidden: true,
				selectedFilter: nil
			)
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

	func didChangeSearchQuery(_ query: String) {
		let normalizedQuery = normalizedSearchQuery(query)
		guard normalizedQuery != searchQuery else { return }
		searchQuerySubject.send(normalizedQuery)
	}

	func didSelectFilterOption(_ option: TrackersFilterOption) {
		selectedFilter = option.persistentFilter

		if option.setsDateToToday {
			let today = calendar.startOfDay(for: Date())
			if selectedDate == today {
				emitState()
			} else {
				selectedDateSubject.send(today)
			}
			return
		}

		emitState()
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
			alertSubject.send(.operationFailed(message: String(localized: "tracker.alert.updateCompletionFailed")))
		}
	}

	func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
		do {
			try trackerStore.add(tracker, toCategoryWithTitle: title)
		} catch {
			assertionFailure("Failed to add tracker: \(error)")
			alertSubject.send(.operationFailed(message: String(localized: "tracker.alert.createFailed")))
		}
	}

	func updateTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
		do {
			try trackerStore.update(tracker, toCategoryWithTitle: title)
		} catch {
			assertionFailure("Failed to update tracker: \(error)")
			alertSubject.send(.operationFailed(message: String(localized: "tracker.alert.updateFailed")))
		}
	}

	func didTapTogglePinned(for trackerID: UUID) {
		guard let trackerContext = trackerContext(for: trackerID) else { return }
		do {
			try trackerStore.setPinned(!trackerContext.tracker.isPinned, for: trackerID)
		} catch {
			assertionFailure("Failed to toggle pinned state: \(error)")
			alertSubject.send(.operationFailed(message: String(localized: "tracker.alert.updatePinFailed")))
		}
	}

	func didTapDeleteTracker(for trackerID: UUID) {
		do {
			try trackerStore.deleteTracker(with: trackerID)
		} catch {
			assertionFailure("Failed to delete tracker: \(error)")
			alertSubject.send(.operationFailed(message: String(localized: "tracker.alert.deleteFailed")))
		}
	}

	func makeTrackerEditingViewModel(for trackerID: UUID) -> TrackerEditorViewModel? {
		guard let trackerContext = trackerContext(for: trackerID) else { return nil }
		let mode: TrackerEditorMode = trackerContext.tracker.schedule.isEmpty ? .irregularEvent : .habit
		return TrackerEditorViewModel(
			mode: mode,
			trackerCategoryStore: trackerCategoryStore,
			initialTracker: trackerContext.tracker,
			initialCategoryTitle: trackerContext.categoryTitle,
			initialCompletedCount: completedCount(for: trackerContext.tracker.id)
		)
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

		searchQuerySubject
			.removeDuplicates()
			.sink { [weak self] query in
				guard let self else { return }
				self.searchQuery = query
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
		let hasTrackersOnSelectedDate = !makeVisibleCategories(
			for: selectedDate,
			searchQuery: "",
			filter: nil
		).isEmpty
		let visibleCategories = makeVisibleCategories(
			for: selectedDate,
			searchQuery: searchQuery,
			filter: selectedFilter
		)
		let sections = makeSections(from: visibleCategories, for: selectedDate)
		let emptyState: EmptyState? = sections.isEmpty
		? ((searchQuery.isEmpty && (!hasTrackersOnSelectedDate || selectedFilter == nil)) ? .noTrackers : .noSearchResults)
		: nil

		stateSubject.send(
			State(
				sections: sections,
				selectedDate: selectedDate,
				emptyState: emptyState,
				isFilterButtonHidden: !hasTrackersOnSelectedDate,
				selectedFilter: selectedFilter
			)
		)
	}

	private func makeVisibleCategories(
		for date: Date,
		searchQuery: String,
		filter: TrackersFilter?
	) -> [TrackerCategory] {
		let weekday = Weekday.from(date, calendar: calendar)

		return categories.compactMap { category in
			let trackers = category.trackers.filter { tracker in
				shouldDisplayTracker(tracker, on: date, weekday: weekday)
				&& matchesCompletionFilter(for: tracker.id, on: date, filter: filter)
				&& matchesSearchQuery(tracker.title, query: searchQuery)
			}

			guard !trackers.isEmpty else { return nil }
			return TrackerCategory(title: category.title, trackers: trackers)
		}
	}

	private func matchesCompletionFilter(
		for trackerID: UUID,
		on date: Date,
		filter: TrackersFilter?,
	) -> Bool {
		guard let filter else { return true }
		let isCompleted = isTrackerCompleted(trackerID: trackerID, on: date)
		switch filter {
		case .completed:
			return isCompleted
		case .notCompleted:
			return !isCompleted
		}
	}

	private func makeSections(
		from categories: [TrackerCategory],
		for date: Date
	) -> [TrackerCategorySectionViewData] {
		var pinnedItems: [TrackerItemViewData] = []
		var regularSections: [TrackerCategorySectionViewData] = []

		for category in categories {
			var regularItems: [TrackerItemViewData] = []
			for tracker in category.trackers {
				let item = TrackerItemViewData(
					tracker: tracker,
					completedCount: completedCount(for: tracker.id),
					isCompletedOnSelectedDate: isTrackerCompleted(trackerID: tracker.id, on: date)
				)

				if tracker.isPinned {
					pinnedItems.append(item)
				} else {
					regularItems.append(item)
				}
			}

			if !regularItems.isEmpty {
				regularSections.append(TrackerCategorySectionViewData(title: category.title, items: regularItems))
			}
		}

		pinnedItems.sort { $0.tracker.createdAt < $1.tracker.createdAt }

		if pinnedItems.isEmpty {
			return regularSections
		}

		return [TrackerCategorySectionViewData(title: String(localized: "tracker.pinned.section"), items: pinnedItems)]
			+ regularSections
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

	private func matchesSearchQuery(_ trackerTitle: String, query: String) -> Bool {
		guard !query.isEmpty else { return true }
		return trackerTitle.localizedCaseInsensitiveContains(query)
	}

	private func normalizedSearchQuery(_ query: String) -> String {
		query.trimmingCharacters(in: .whitespacesAndNewlines)
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

	private func trackerContext(for trackerID: UUID) -> (tracker: Tracker, categoryTitle: String)? {
		for category in categories {
			if let tracker = category.trackers.first(where: { $0.id == trackerID }) {
				return (tracker, category.title)
			}
		}
		return nil
	}
}
