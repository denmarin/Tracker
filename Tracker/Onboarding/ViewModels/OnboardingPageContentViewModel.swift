//
//  OnboardingPageContentViewModel.swift
//  Tracker
//

import UIKit

struct OnboardingPage {
	let title: String
	let backgroundImageName: String
	let fallbackTopColor: UIColor
	let fallbackBottomColor: UIColor
}

final class OnboardingPageContentViewModel {
	struct State {
		let title: String
		let backgroundImageName: String
		let fallbackTopColor: UIColor
		let fallbackBottomColor: UIColor
	}

	let state: State

	init(page: OnboardingPage) {
		self.state = State(
			title: page.title,
			backgroundImageName: page.backgroundImageName,
			fallbackTopColor: page.fallbackTopColor,
			fallbackBottomColor: page.fallbackBottomColor
		)
	}
}
