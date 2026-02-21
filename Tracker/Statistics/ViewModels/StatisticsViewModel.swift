//
//  StatisticsViewModel.swift
//  Tracker
//

import Foundation

final class StatisticsViewModel {
	struct State {
		let title: String
	}

	var onStateChanged: ((State) -> Void)?

	func viewDidLoad() {
		onStateChanged?(State(title: "Статистика"))
	}
}
