//
//  TrackerDaysTextFormatter.swift
//  Tracker
//
//  Created by Codex on 09.03.26.
//

import Foundation

enum TrackerDaysTextFormatter {
	static func makeDaysCountText(for count: Int) -> String {
		let format = String(localized: "tracker.days.count.format")
		let countText = String(count)
		let dayWord = localizedDayWord(for: count)
		return String(format: format, locale: Locale.current, countText, dayWord)
	}

	private static func localizedDayWord(for count: Int) -> String {
		let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
		if languageCode == "ru" {
			let mod10 = count % 10
			let mod100 = count % 100
			if mod10 == 1 && mod100 != 11 {
				return String(localized: "tracker.dayWord.one")
			}
			if (2...4).contains(mod10) && !(12...14).contains(mod100) {
				return String(localized: "tracker.dayWord.few")
			}
			return String(localized: "tracker.dayWord.many")
		}

		return count == 1
			? String(localized: "tracker.dayWord.one")
			: String(localized: "tracker.dayWord.other")
	}
}
