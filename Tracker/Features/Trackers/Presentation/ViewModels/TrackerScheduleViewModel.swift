//
//  TrackerScheduleViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation
import Combine

struct TrackerScheduleDayRowViewData {
	let title: String
	let isSelected: Bool
}

final class TrackerScheduleViewModel {
	var rowsPublisher: AnyPublisher<[TrackerScheduleDayRowViewData], Never> {
		rowsSubject.eraseToAnyPublisher()
	}
	var doneSelectionPublisher: AnyPublisher<Set<Weekday>, Never> {
		doneSelectionSubject.eraseToAnyPublisher()
	}

	private let daysOrder: [Weekday] = Weekday.ordered
	private var selection: Set<Weekday>
	private let rowsSubject = CurrentValueSubject<[TrackerScheduleDayRowViewData], Never>([])
	private let doneSelectionSubject = PassthroughSubject<Set<Weekday>, Never>()

	init(initialSelection: Set<Weekday>) {
		self.selection = initialSelection
	}

	func viewDidLoad() {
		emitRows()
	}

	func didTapDone() {
		doneSelectionSubject.send(selection)
	}

	func didToggleDay(at index: Int) {
		guard daysOrder.indices.contains(index) else { return }
		let day = daysOrder[index]

		if selection.contains(day) {
			selection.remove(day)
		} else {
			selection.insert(day)
		}

		emitRows()
	}

	private func emitRows() {
		let rows = daysOrder.map { day in
			TrackerScheduleDayRowViewData(
				title: day.fullName,
				isSelected: selection.contains(day)
			)
		}
		rowsSubject.send(rows)
	}
}
