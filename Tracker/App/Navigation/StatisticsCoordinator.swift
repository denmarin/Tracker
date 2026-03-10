//
//  StatisticsCoordinator.swift
//  Tracker
//

import UIKit

final class StatisticsCoordinator {
	private let trackerStore: TrackerStore
	private let trackerRecordStore: TrackerRecordStore

	init(
		trackerStore: TrackerStore,
		trackerRecordStore: TrackerRecordStore
	) {
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
	}

	@discardableResult
	func start() -> UIViewController {
		let statisticsViewController = StatisticsViewController(
			viewModel: StatisticsViewModel(
				trackerStore: trackerStore,
				trackerRecordStore: trackerRecordStore
			)
		)

		let navigationController = UINavigationController(rootViewController: statisticsViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: String(localized: "tab.statistics"),
			image: UIImage(systemName: "hare.fill"),
			selectedImage: UIImage(systemName: "hare.fill")
		)
		return navigationController
	}
}
