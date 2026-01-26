//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class HabitCreationViewController: TrackerCreationBaseViewController {

	private let categoryRow = SettingsRowButton()
	private let scheduleRow = SettingsRowButton()

	private var selectedSchedule: Set<Weekday> = [] {
		didSet {
			scheduleRow.setValueText(scheduleSummary(from: selectedSchedule))
			updateCreateButtonState()
		}
	}

	override var screenTitle: String { "Новая привычка" }

	override func makeRows() -> [UIView] {
		categoryRow.configure(title: "Категория")
		scheduleRow.configure(title: "Расписание")
		scheduleRow.setValueText(scheduleSummary(from: selectedSchedule))

		categoryRow.addAction(UIAction { [weak self] _ in
			self?.presentNotImplementedAlert()
		}, for: .touchUpInside)

		scheduleRow.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			let vc = ScheduleSelectionViewController(initialSelection: self.selectedSchedule)
			vc.onDone = { [weak self] selection in
				self?.selectedSchedule = selection
			}
			self.navigationController?.pushViewController(vc, animated: true)
		}, for: .touchUpInside)

		return [categoryRow, scheduleRow]
	}

	override func isFormValid(title: String) -> Bool {
		!title.isEmpty && !selectedSchedule.isEmpty
	}

	override func makeTracker(title: String) -> Tracker {
		Tracker(title: title, emoji: "🙂", color: .systemBlue, schedule: selectedSchedule)
	}

	private func scheduleSummary(from selection: Set<Weekday>) -> String {
		if selection.count == Weekday.allCases.count { return "Каждый день" }
		let items = Weekday.ordered
			.filter { selection.contains($0) }
			.map { $0.shortName }
		return items.joined(separator: ", ")
	}
}
