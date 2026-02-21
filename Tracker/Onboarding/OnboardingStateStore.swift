//
//  OnboardingStateStore.swift
//  Tracker
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

