//
//  TrackerTypeSelectionViewModel.swift
//  Tracker
//

import Foundation

final class TrackerTypeSelectionViewModel {
	var onRouteToCreation: ((CreationViewModel) -> Void)?

	private let trackerCategoryStore: TrackerCategoryStore
	private let onCreate: (Tracker, String) -> Void

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
		creationViewModel.onCreate = onCreate
		onRouteToCreation?(creationViewModel)
	}
}
