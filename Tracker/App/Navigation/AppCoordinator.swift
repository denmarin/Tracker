//
//  AppCoordinator.swift
//  Tracker
//

import UIKit

final class AppCoordinator {
	private let window: UIWindow
	private let dependencies: AppDependencyContainer
	private let onboardingStateStore: OnboardingStateStore

	private var trackersCoordinator: TrackersCoordinator?
	private var statisticsCoordinator: StatisticsCoordinator?

	init(
		window: UIWindow,
		dependencies: AppDependencyContainer,
		onboardingStateStore: OnboardingStateStore = OnboardingStateStore()
	) {
		self.window = window
		self.dependencies = dependencies
		self.onboardingStateStore = onboardingStateStore
	}

	func start() {
		if onboardingStateStore.hasSeenOnboarding {
			showMainRoot(animated: false)
		} else {
			showOnboardingRoot()
		}
	}

	private func showOnboardingRoot() {
		let onboardingViewController = OnboardingViewController(
			viewModel: OnboardingViewModel()
		)
		onboardingViewController.onFinish = { [weak self] in
			self?.finishOnboardingFlow()
		}
		window.rootViewController = onboardingViewController
	}

	private func finishOnboardingFlow() {
		onboardingStateStore.markOnboardingAsSeen()
		showMainRoot(animated: true)
	}

	private func showMainRoot(animated: Bool) {
		let trackersCoordinator = TrackersCoordinator(
			trackerStore: dependencies.trackerStore,
			trackerRecordStore: dependencies.trackerRecordStore,
			trackerCategoryStore: dependencies.trackerCategoryStore
		)
		let statisticsCoordinator = StatisticsCoordinator(
			trackerStore: dependencies.trackerStore,
			trackerRecordStore: dependencies.trackerRecordStore
		)
		self.trackersCoordinator = trackersCoordinator
		self.statisticsCoordinator = statisticsCoordinator

		let tabBarController = UITabBarController()
		tabBarController.viewControllers = [
			trackersCoordinator.start(),
			statisticsCoordinator.start()
		]

		guard animated, window.rootViewController != nil else {
			window.rootViewController = tabBarController
			return
		}

		UIView.transition(
			with: window,
			duration: 0.3,
			options: [.transitionCrossDissolve, .allowAnimatedContent]
		) {
			self.window.rootViewController = tabBarController
		}
	}
}
