//
//  OnboardingViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import UIKit
import Combine

final class OnboardingViewModel {
	var currentPagePublisher: AnyPublisher<Int, Never> {
		currentPageSubject.eraseToAnyPublisher()
	}
	var finishPublisher: AnyPublisher<Void, Never> {
		finishSubject.eraseToAnyPublisher()
	}

	let pages: [OnboardingPage]
	private var currentPageIndex: Int
	private let currentPageSubject: CurrentValueSubject<Int, Never>
	private let finishSubject = PassthroughSubject<Void, Never>()

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
		self.currentPageSubject = CurrentValueSubject(self.currentPageIndex)
	}

	func viewDidLoad() {
		currentPageSubject.send(currentPageIndex)
	}

	func didFinishTransition(to index: Int) {
		guard pages.indices.contains(index) else { return }
		currentPageIndex = index
		currentPageSubject.send(index)
	}

	func didTapActionButton() {
		finishSubject.send(())
	}

	private static let defaultPages: [OnboardingPage] = [
		OnboardingPage(
			title: "Отслеживайте только\nто, что хотите",
			backgroundImageName: "OnboardingBackgroundBlue",
			fallbackTopColor: OnboardingPalette.blueTop,
			fallbackBottomColor: OnboardingPalette.blueBottom
		),
		OnboardingPage(
			title: "Даже если это\nне литры воды и йога",
			backgroundImageName: "OnboardingBackgroundRed",
			fallbackTopColor: OnboardingPalette.redTop,
			fallbackBottomColor: OnboardingPalette.redBottom
		)
	]
}
