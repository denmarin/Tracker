//
//  StatisticsViewModel.swift
//  Tracker
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
		State(title: "Статистика")
	)

	func viewDidLoad() {
		stateSubject.send(State(title: "Статистика"))
	}
}
