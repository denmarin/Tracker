//
//  TrackersCoordinator.swift
//  Tracker
//

import UIKit
import Combine

final class TrackersCoordinator {
	private enum SFSymbol {
		static let trackersTab = "record.circle.fill"
	}

	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore
	private let trackerCategoryStore: TrackerCategoryStore

	private var cancellables = Set<AnyCancellable>()

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore,
		trackerCategoryStore: TrackerCategoryStore
	) {
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.trackerCategoryStore = trackerCategoryStore
	}

	@discardableResult
	func start() -> UIViewController {
		let trackersViewModel = TrackersViewModel(
			trackerStore: trackerStore,
			trackerRecordStore: trackerRecordStore,
			trackerCategoryStore: trackerCategoryStore
		)
		let trackersViewController = TrackersViewController(viewModel: trackersViewModel)
		trackersViewController.onRequestTrackerTypeSelection = { [weak self, weak trackersViewController] in
			guard let self, let trackersViewController else { return }
			self.presentTrackerTypeSelection(
				from: trackersViewController,
				using: trackersViewModel
			)
		}
		trackersViewController.onRequestTrackerEditing = { [weak self, weak trackersViewController] trackerID in
			guard let self, let trackersViewController else { return }
			self.presentTrackerEditing(
				for: trackerID,
				from: trackersViewController,
				using: trackersViewModel
			)
		}

		let navigationController = UINavigationController(rootViewController: trackersViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: String(localized: "tab.trackers"),
			image: UIImage(systemName: SFSymbol.trackersTab),
			selectedImage: UIImage(systemName: SFSymbol.trackersTab)
		)
		return navigationController
	}

	private func presentTrackerTypeSelection(
		from sourceViewController: UIViewController,
		using trackersViewModel: TrackersViewModel
	) {
		let typeViewModel = trackersViewModel.makeTrackerTypeSelectionViewModel { [weak trackersViewModel] tracker, categoryTitle in
			trackersViewModel?.addTracker(tracker, toCategoryWithTitle: categoryTitle)
		}
		let typeViewController = TrackerTypeSelectionViewController(viewModel: typeViewModel)
		typeViewController.onRequestOpenEditor = { [weak self, weak typeViewController] editorViewModel in
			guard let self, let navigationController = typeViewController?.navigationController else { return }
			let editorViewController = self.makeEditorViewController(
				viewModel: editorViewModel,
				onSaveTracker: nil
			)
			navigationController.pushViewController(editorViewController, animated: true)
		}

		let navigationController = UINavigationController(rootViewController: typeViewController)
		configurePageSheet(for: navigationController)
		sourceViewController.present(navigationController, animated: true)
	}

	private func presentTrackerEditing(
		for trackerID: UUID,
		from sourceViewController: UIViewController,
		using trackersViewModel: TrackersViewModel
	) {
		guard let editorViewModel = trackersViewModel.makeTrackerEditingViewModel(for: trackerID) else { return }
		let editorViewController = makeEditorViewController(
			viewModel: editorViewModel,
			onSaveTracker: { [weak trackersViewModel] tracker, categoryTitle in
				trackersViewModel?.updateTracker(tracker, toCategoryWithTitle: categoryTitle)
			}
		)

		let navigationController = UINavigationController(rootViewController: editorViewController)
		configurePageSheet(for: navigationController)
		sourceViewController.present(navigationController, animated: true)
	}

	private func makeEditorViewController(
		viewModel: TrackerEditorViewModel,
		onSaveTracker: ((Tracker, String) -> Void)?
	) -> TrackerEditorViewController {
		if let onSaveTracker {
			viewModel.saveTrackerPublisher
				.prefix(1)
				.receive(on: RunLoop.main)
				.sink(receiveValue: onSaveTracker)
				.store(in: &cancellables)
		}

		let editorViewController = TrackerEditorViewController(viewModel: viewModel)
		editorViewController.onRequestCategorySelection = { [weak self, weak editorViewController] categoryListViewModel, onCategorySelected in
			guard let self, let navigationController = editorViewController?.navigationController else { return }
			self.showCategorySelection(
				viewModel: categoryListViewModel,
				onCategorySelected: onCategorySelected,
				in: navigationController
			)
		}
		editorViewController.onRequestScheduleSelection = { [weak self, weak editorViewController] scheduleViewModel, onScheduleSelected in
			guard let self, let navigationController = editorViewController?.navigationController else { return }
			self.showScheduleSelection(
				viewModel: scheduleViewModel,
				onScheduleSelected: onScheduleSelected,
				in: navigationController
			)
		}
		return editorViewController
	}

	private func showCategorySelection(
		viewModel: TrackerCategoryListViewModel,
		onCategorySelected: @escaping (String?) -> Void,
		in navigationController: UINavigationController
	) {
		let categoryListViewController = TrackerCategoryListViewController(viewModel: viewModel)
		categoryListViewController.onSelectedCategoryChanged = onCategorySelected
		navigationController.pushViewController(categoryListViewController, animated: true)
	}

	private func showScheduleSelection(
		viewModel: TrackerScheduleViewModel,
		onScheduleSelected: @escaping (Set<Weekday>) -> Void,
		in navigationController: UINavigationController
	) {
		viewModel.doneSelectionPublisher
			.prefix(1)
			.receive(on: RunLoop.main)
			.sink(receiveValue: onScheduleSelected)
			.store(in: &cancellables)

		let scheduleViewController = TrackerScheduleViewController(viewModel: viewModel)
		navigationController.pushViewController(scheduleViewController, animated: true)
	}

	private func configurePageSheet(for viewController: UIViewController) {
		viewController.modalPresentationStyle = .pageSheet
		if let sheet = viewController.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = false
			if #available(iOS 16.0, *) {
				sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			}
		}
	}
}
