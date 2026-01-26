//
//  IrregularEventCreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class IrregularEventCreationViewController: TrackerCreationBaseViewController {

	private let categoryRow = SettingsRowButton()

	override var screenTitle: String { "Новое нерегулярное событие" }

	override func makeRows() -> [UIView] {
		categoryRow.configure(title: "Категория")
		categoryRow.addAction(UIAction { [weak self] _ in
			self?.presentNotImplementedAlert()
		}, for: .touchUpInside)
		return [categoryRow]
	}

	override func makeTracker(title: String) -> Tracker {
		Tracker(title: title, emoji: "🙂", color: .systemBlue, schedule: [])
	}
}
