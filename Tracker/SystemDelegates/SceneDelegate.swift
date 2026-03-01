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
	private let onboardingStateStore = OnboardingStateStore()

	// MARK: - UIWindowSceneDelegate

	func scene(
		_ scene: UIScene,
		willConnectTo session: UISceneSession,
		options connectionOptions: UIScene.ConnectionOptions
	) {
		guard let windowScene = scene as? UIWindowScene else { return }

		let window = makeWindow(windowScene: windowScene)
		window.rootViewController = makeInitialRootViewController()
		window.makeKeyAndVisible()

		self.window = window
	}

	// MARK: - Window

	private func makeWindow(windowScene: UIWindowScene) -> UIWindow {
		UIWindow(windowScene: windowScene)
	}

	// MARK: - Root View Controller

	private func makeInitialRootViewController() -> UIViewController {
		if onboardingStateStore.hasSeenOnboarding {
			return makeMainRootViewController()
		}
		return makeOnboardingViewController()
	}

	private func makeMainRootViewController() -> UIViewController {
		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [
			makeTrackersNavigationController(),
			makeStatisticsNavigationController()
		]
		return tabBarController
	}

	private func makeOnboardingViewController() -> UIViewController {
		let onboardingViewController = OnboardingViewController(
			viewModel: OnboardingViewModel()
		)
		onboardingViewController.onFinish = { [weak self] in
			self?.finishOnboardingFlow()
		}
		return onboardingViewController
	}

	private func finishOnboardingFlow() {
		onboardingStateStore.markOnboardingAsSeen()
		transitionToMainRoot()
	}

	private func transitionToMainRoot() {
		guard let window else { return }
		let mainRoot = makeMainRootViewController()

		UIView.transition(
			with: window,
			duration: 0.3,
			options: [.transitionCrossDissolve, .allowAnimatedContent]
		) {
			window.rootViewController = mainRoot
		}
	}

	// MARK: - Navigation Controllers

	private func makeTrackersNavigationController() -> UINavigationController {
		let trackerCategoryStore = makeTrackerCategoryStore()
		let trackersViewModel = TrackersViewModel(
			trackerStore: makeTrackerStore(categoryStore: trackerCategoryStore),
			trackerRecordStore: makeTrackerRecordStore(),
			trackerCategoryStore: trackerCategoryStore
		)
		let trackersViewController = TrackersViewController(viewModel: trackersViewModel)

		let navigationController = UINavigationController(rootViewController: trackersViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: String(localized: "tab.trackers"),
			image: UIImage(systemName: "record.circle.fill"),
			selectedImage: UIImage(systemName: "record.circle.fill")
		)
		return navigationController
	}

	private func makeStatisticsNavigationController() -> UINavigationController {
		let statisticsViewController = StatisticsViewController(viewModel: StatisticsViewModel())
		let navigationController = UINavigationController(rootViewController: statisticsViewController)
		navigationController.tabBarItem = UITabBarItem(
			title: String(localized: "tab.statistics"),
			image: UIImage(systemName: "hare.fill"),
			selectedImage: UIImage(systemName: "hare.fill")
		)
		return navigationController
	}

	// MARK: - Stores

	private func makeTrackerStore(categoryStore: TrackerCategoryStore) -> TrackerStore {
		TrackerStore(
			coreDataStack: coreDataStack,
			categoryStore: categoryStore
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
