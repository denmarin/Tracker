//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//

import Foundation
import Combine

final class TrackerTypeSelectionViewModel {
	var routeToCreationPublisher: AnyPublisher<CreationViewModel, Never> {
		routeToCreationSubject.eraseToAnyPublisher()
	}

	private let trackerCategoryStore: TrackerCategoryStore
	private let onCreate: (Tracker, String) -> Void
	private let routeToCreationSubject = PassthroughSubject<CreationViewModel, Never>()
	private var cancellables = Set<AnyCancellable>()

	init(
		trackerCategoryStore: TrackerCategoryStore,
		onCreate: @escaping (Tracker, String) -> Void
	) {
		self.trackerCategoryStore = trackerCategoryStore
		self.onCreate = onCreate
	}

	func didSelectHabit() {
		routeToCreation(mode: .habit)
	}

	func didSelectIrregularEvent() {
		routeToCreation(mode: .irregularEvent)
	}

	private func routeToCreation(mode: TrackerCreationMode) {
		let creationViewModel = CreationViewModel(
			mode: mode,
			trackerCategoryStore: trackerCategoryStore
		)
		creationViewModel.createTrackerPublisher
			.sink { [onCreate] tracker, category in
				onCreate(tracker, category)
			}
			.store(in: &cancellables)
		routeToCreationSubject.send(creationViewModel)
	}
}
