//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 12.01.26.
//


import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	// MARK: - Properties

	var window: UIWindow?

	// MARK: - UIWindowSceneDelegate

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = scene as? UIWindowScene else { return }

		let window = makeWindow(windowScene: windowScene)
		window.rootViewController = makeRootViewController()
		window.makeKeyAndVisible()

		self.window = window
	}

	// MARK: - Window

	private func makeWindow(windowScene: UIWindowScene) -> UIWindow {
		UIWindow(windowScene: windowScene)
	}

	// MARK: - Root View Controller

	private func makeRootViewController() -> UIViewController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [
			makeTrackersNavigationController(),
			makeStatisticsNavigationController()
		]
		return tabBarController
	}

	// MARK: - Navigation Controllers

	private func makeTrackersNavigationController() -> UINavigationController {
		let trackersViewController = TrackersViewController(
			trackerStore: makeTrackerStore(),
			trackerRecordStore: makeTrackerRecordStore()
		)

		let navigationController = UINavigationController(rootViewController: trackersViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: "Трекеры",
			image: UIImage(systemName: "record.circle.fill"),
			selectedImage: UIImage(systemName: "record.circle.fill")
		)
		return navigationController
	}

	private func makeStatisticsNavigationController() -> UINavigationController {
		let statisticsViewController = StatisticsViewController()
		let navigationController = UINavigationController(rootViewController: statisticsViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: "Статистика",
			image: UIImage(systemName: "hare.fill"),
			selectedImage: UIImage(systemName: "hare.fill")
		)
		return navigationController
	}

	// MARK: - Stores

	private func makeTrackerStore() -> TrackerStore {
		TrackerStore(
			coreDataStack: coreDataStack,
			categoryStore: makeTrackerCategoryStore()
		)
	}

	private func makeTrackerCategoryStore() -> TrackerCategoryStore {
		TrackerCategoryStore(coreDataStack: coreDataStack)
	}

	private func makeTrackerRecordStore() -> TrackerRecordStore {
		TrackerRecordStore(coreDataStack: coreDataStack)
	}

	// MARK: - Core Data

	private var coreDataStack: CoreDataStack {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			fatalError("AppDelegate not found")
		}
		return appDelegate.coreDataStack
	}
}
