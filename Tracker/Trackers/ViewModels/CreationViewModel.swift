//
//  CreationViewModel.swift
//  Tracker
//

import UIKit

enum TrackerCreationMode {
	case habit
	case irregularEvent

	var screenTitle: String {
		switch self {
		case .habit:
			return "Новая привычка"
		case .irregularEvent:
			return "Новое нерегулярное событие"
		}
	}

	var requiresSchedule: Bool {
		switch self {
		case .habit:
			return true
		case .irregularEvent:
			return false
		}
	}
}

final class CreationViewModel {
	struct State {
		let screenTitle: String
		let title: String
		let selectedCategoryTitle: String?
		let selectedEmoji: String?
		let selectedColorIndex: Int?
		let scheduleSummary: String?
		let isTitleTooLong: Bool
		let isCreateEnabled: Bool
	}

	var onStateChanged: ((State) -> Void)?
	var onDismissRequested: (() -> Void)?
	var onCreate: ((Tracker, String) -> Void)?

	let mode: TrackerCreationMode
	let emojis: [String] = [
		"🙂", "😻", "🌺", "🐶", "❤️", "😱",
		"😇", "😡", "🥶", "🤔", "🙌", "🍔",
		"🥦", "🏓", "🥇", "🎸", "🏝", "😪"
	]
	let colorAssetNames: [String] = (1...18).map { "ColorSelect\($0)" }

	private let trackerCategoryStore: TrackerCategoryStore
	private let maxTitleLength = 38

	private var title = ""
	private var selectedCategoryTitle: String?
	private var selectedEmoji: String?
	private var selectedColorIndex: Int?
	private var selectedSchedule: Set<Weekday> = []

	init(mode: TrackerCreationMode, trackerCategoryStore: TrackerCategoryStore) {
		self.mode = mode
		self.trackerCategoryStore = trackerCategoryStore
	}

	func viewDidLoad() {
		emitState()
	}

	func didTapCancel() {
		onDismissRequested?()
	}

	func didTapCreate() {
		guard let payload = makeCreationPayload() else { return }
		onCreate?(payload.tracker, payload.categoryTitle)
		onDismissRequested?()
	}

	func updateTitle(_ rawTitle: String) {
		title = rawTitle
		emitState()
	}

	func selectEmoji(at index: Int) {
		guard emojis.indices.contains(index) else { return }
		selectedEmoji = emojis[index]
		emitState()
	}

	func selectColor(at index: Int) {
		guard colorAssetNames.indices.contains(index) else { return }
		selectedColorIndex = index
		emitState()
	}

	func updateSelectedCategory(title: String?) {
		selectedCategoryTitle = title
		emitState()
	}

	func updateSchedule(_ selection: Set<Weekday>) {
		guard mode.requiresSchedule else { return }
		selectedSchedule = selection
		emitState()
	}

	func currentScheduleSelection() -> Set<Weekday> {
		selectedSchedule
	}

	func makeCategoryListViewModel() -> CategoryListViewModel {
		CategoryListViewModel(
			categoryStore: trackerCategoryStore,
			initiallySelectedCategoryTitle: selectedCategoryTitle
		)
	}

	private func emitState() {
		onStateChanged?(
			State(
				screenTitle: mode.screenTitle,
				title: title,
				selectedCategoryTitle: selectedCategoryTitle,
				selectedEmoji: selectedEmoji,
				selectedColorIndex: selectedColorIndex,
				scheduleSummary: mode.requiresSchedule ? scheduleSummary(from: selectedSchedule) : nil,
				isTitleTooLong: title.count > maxTitleLength,
				isCreateEnabled: canCreateTracker()
			)
		)
	}

	private func canCreateTracker() -> Bool {
		guard title.count <= maxTitleLength else { return false }
		guard !normalizedTitle.isEmpty else { return false }
		guard selectedCategoryTitle != nil else { return false }
		guard selectedEmoji != nil else { return false }
		guard selectedColorIndex != nil else { return false }

		if mode.requiresSchedule {
			return !selectedSchedule.isEmpty
		}
		return true
	}

	private func makeCreationPayload() -> (tracker: Tracker, categoryTitle: String)? {
		guard canCreateTracker() else { return nil }
		guard let emoji = selectedEmoji else { return nil }
		guard let selectedColorIndex else { return nil }
		guard let categoryTitle = selectedCategoryTitle else { return nil }

		let colorName = colorAssetNames[selectedColorIndex]
		let color = UIColor(named: colorName) ?? .systemBlue

		let tracker = Tracker(
			title: normalizedTitle,
			emoji: emoji,
			color: color,
			schedule: mode.requiresSchedule ? selectedSchedule : []
		)
		return (tracker, categoryTitle)
	}

	private var normalizedTitle: String {
		title.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func scheduleSummary(from selection: Set<Weekday>) -> String {
		if selection.isEmpty { return "" }
		if selection.count == Weekday.allCases.count { return "Каждый день" }
		return Weekday.ordered
			.filter { selection.contains($0) }
			.map(\.shortName)
			.joined(separator: ", ")
	}
}
