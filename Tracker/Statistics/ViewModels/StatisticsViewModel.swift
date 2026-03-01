//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation
import Combine

final class StatisticsViewModel {
	struct State {
		let title: String
	}

	var statePublisher: AnyPublisher<State, Never> {
		stateSubject.eraseToAnyPublisher()
	}

	private let stateSubject = CurrentValueSubject<State, Never>(
		State(title: String(localized: "statistics.title"))
	)

	func viewDidLoad() {
		stateSubject.send(State(title: String(localized: "statistics.title")))
	}
}
