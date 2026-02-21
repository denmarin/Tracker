//
//  ScheduleSelectionViewModel.swift
//  Tracker
//

import Foundation

struct ScheduleDayRowViewData {
	let title: String
	let isSelected: Bool
}

final class ScheduleSelectionViewModel {
	var onRowsChanged: (([ScheduleDayRowViewData]) -> Void)?
	var onDoneSelection: ((Set<Weekday>) -> Void)?

	private let daysOrder: [Weekday] = Weekday.ordered
	private var selection: Set<Weekday>

	init(initialSelection: Set<Weekday>) {
		self.selection = initialSelection
	}

	func viewDidLoad() {
		emitRows()
	}

	func didTapDone() {
		onDoneSelection?(selection)
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
			ScheduleDayRowViewData(
				title: day.fullName,
				isSelected: selection.contains(day)
			)
		}
		onRowsChanged?(rows)
	}
}
