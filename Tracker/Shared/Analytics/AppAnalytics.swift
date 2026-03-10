//
//  AppAnalytics.swift
//  Tracker
//
//  Created by Codex on 09.03.26.
//

import Foundation
import AppMetricaCore

enum AnalyticsScreen: String {
	case main = "Main"
	case statistics = "Statistics"
	case onboarding = "Onboarding"
	case trackerTypeSelection = "TrackerTypeSelection"
	case habitCreation = "HabitCreation"
	case irregularEventCreation = "IrregularEventCreation"
	case categoryList = "CategoryList"
	case categoryEditor = "CategoryEditor"
	case schedule = "Schedule"
	case filters = "Filters"
}

enum AnalyticsItem: String {
	case addTrack = "add_track"
	case track
	case filter
	case edit
	case delete
	case onboardingAction = "onboarding_action"
	case habit
	case irregularEvent = "irregular_event"
	case category
	case schedule
	case create
	case cancel
	case done
	case emoji
	case color
	case categorySelection = "category_selection"
	case addCategory = "add_category"
	case day
	case filterOption = "filter_option"
}

private enum AnalyticsEvent: String {
	case open
	case close
	case click
}

final class AppAnalytics {
	static let shared = AppAnalytics()

	private let apiKeyInfoPlistKey = "APPMETRICA_API_KEY"
	private lazy var apiKey: String? = {
		Bundle.main.object(forInfoDictionaryKey: apiKeyInfoPlistKey) as? String
	}()

	private init() {}

	func activateIfNeeded() {
		guard AppMetrica.isActivated == false else { return }

		guard
			let apiKey,
			apiKey.isEmpty == false
		else {
			log("AppMetrica key is missing in Info.plist (\(apiKeyInfoPlistKey))")
			return
		}

		guard let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
			log("Failed to create AppMetricaConfiguration")
			return
		}

		#if DEBUG
		configuration.areLogsEnabled = true
		configuration.dispatchPeriod = 5
		#endif

		AppMetrica.activate(with: configuration)
		log("AppMetrica activated")
	}

	func open(_ screen: AnalyticsScreen) {
		send(.open, screen: screen)
	}

	func close(_ screen: AnalyticsScreen) {
		send(.close, screen: screen)
	}

	func click(_ screen: AnalyticsScreen, item: AnalyticsItem) {
		send(.click, screen: screen, item: item)
	}

	private func send(_ event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem? = nil) {
		activateIfNeeded()
		guard AppMetrica.isActivated else { return }

		var payload: [String: String] = ["event": event.rawValue, "screen": screen.rawValue]
		if event == .click, let item {
			payload["item"] = item.rawValue
		}

		AppMetrica.reportEvent(name: event.rawValue, parameters: payload) { [weak self] error in
			self?.log("Failed to send event: \(error.localizedDescription)")
		}

		#if DEBUG
		log("payload: \(payload)")
		#endif
	}

	private func log(_ message: String) {
		#if DEBUG
		print("[Analytics] \(message)")
		#endif
	}
}
