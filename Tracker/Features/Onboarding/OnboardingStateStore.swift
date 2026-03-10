//
//  OnboardingStateStore.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 19.02.26.
//


import Foundation

final class OnboardingStateStore {
	private enum Keys {
		static let hasSeenOnboarding = "hasSeenOnboarding"
	}

	private let userDefaults: UserDefaults

	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}

	var hasSeenOnboarding: Bool {
		userDefaults.bool(forKey: Keys.hasSeenOnboarding)
	}

	func markOnboardingAsSeen() {
		userDefaults.set(true, forKey: Keys.hasSeenOnboarding)
	}
}

