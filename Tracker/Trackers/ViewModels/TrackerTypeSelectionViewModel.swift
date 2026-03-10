//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation
import Combine

final class TrackerTypeSelectionViewModel {
	var routeToEditorPublisher: AnyPublisher<TrackerEditorViewModel, Never> {
		routeToEditorSubject.eraseToAnyPublisher()
	}

	private let trackerCategoryStore: TrackerCategoryStore
	private let onCreate: (Tracker, String) -> Void
	private let routeToEditorSubject = PassthroughSubject<TrackerEditorViewModel, Never>()
	private var cancellables = Set<AnyCancellable>()

	init(
		trackerCategoryStore: TrackerCategoryStore,
		onCreate: @escaping (Tracker, String) -> Void
	) {
		self.trackerCategoryStore = trackerCategoryStore
		self.onCreate = onCreate
	}

	func didSelectHabit() {
		routeToEditor(mode: .habit)
	}

	func didSelectIrregularEvent() {
		routeToEditor(mode: .irregularEvent)
	}

	private func routeToEditor(mode: TrackerEditorMode) {
		let creationViewModel = TrackerEditorViewModel(
			mode: mode,
			trackerCategoryStore: trackerCategoryStore
		)
		creationViewModel.saveTrackerPublisher
			.sink { [onCreate] tracker, category in
				onCreate(tracker, category)
			}
			.store(in: &cancellables)
		routeToEditorSubject.send(creationViewModel)
	}
}
