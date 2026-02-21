//
//  OnboardingViewModel.swift
//  Tracker
//

import UIKit

final class OnboardingViewModel {
	var onCurrentPageChanged: ((Int) -> Void)?
	var onFinishRequested: (() -> Void)?

	let pages: [OnboardingPage]
	private var currentPageIndex: Int

	init(
		pages: [OnboardingPage] = OnboardingViewModel.defaultPages,
		initialPageIndex: Int = 0
	) {
		self.pages = pages
		if pages.indices.contains(initialPageIndex) {
			self.currentPageIndex = initialPageIndex
		} else {
			self.currentPageIndex = 0
		}
	}

	func viewDidLoad() {
		onCurrentPageChanged?(currentPageIndex)
	}

	func didFinishTransition(to index: Int) {
		guard pages.indices.contains(index) else { return }
		currentPageIndex = index
		onCurrentPageChanged?(index)
	}

	func didTapActionButton() {
		onFinishRequested?()
	}

	private static let defaultPages: [OnboardingPage] = [
		OnboardingPage(
			title: "Отслеживайте только\nто, что хотите",
			backgroundImageName: "OnboardingBackgroundBlue",
			fallbackTopColor: UIColor(red: 0.28, green: 0.46, blue: 0.87, alpha: 1.0),
			fallbackBottomColor: UIColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 1.0)
		),
		OnboardingPage(
			title: "Даже если это\nне литры воды и йога",
			backgroundImageName: "OnboardingBackgroundRed",
			fallbackTopColor: UIColor(red: 0.94, green: 0.43, blue: 0.46, alpha: 1.0),
			fallbackBottomColor: UIColor(red: 0.96, green: 0.88, blue: 0.89, alpha: 1.0)
		)
	]
}
