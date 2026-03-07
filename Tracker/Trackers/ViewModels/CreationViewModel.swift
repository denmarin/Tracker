//
//  CreationViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import UIKit
import Combine

enum TrackerCreationMode {
	case habit
	case irregularEvent

	var screenTitle: String {
		switch self {
		case .habit:
			return String(localized: "tracker.creation.habit.title")
		case .irregularEvent:
			return String(localized: "tracker.creation.irregular.title")
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

	var editScreenTitle: String {
		switch self {
		case .habit:
			return String(localized: "tracker.edit.habit.title")
		case .irregularEvent:
			return String(localized: "tracker.edit.irregular.title")
		}
	}
}

final class CreationViewModel {
	private enum SubmissionMode {
		case create
		case edit(originalTrackerID: UUID, createdAt: Date, isPinned: Bool)
	}

	struct State {
		let screenTitle: String
		let submitButtonTitle: String
		let title: String
		let selectedCategoryTitle: String?
		let selectedEmoji: String?
		let selectedColorIndex: Int?
		let scheduleSummary: String?
		let isTitleTooLong: Bool
		let isCreateEnabled: Bool
	}

	var statePublisher: AnyPublisher<State, Never> {
		stateSubject.eraseToAnyPublisher()
	}
	var dismissPublisher: AnyPublisher<Void, Never> {
		dismissSubject.eraseToAnyPublisher()
	}
	var createTrackerPublisher: AnyPublisher<(Tracker, String), Never> {
		createTrackerSubject.eraseToAnyPublisher()
	}

	let mode: TrackerCreationMode
	let emojis: [String] = [
		"🙂", "😻", "🌺", "🐶", "❤️", "😱",
		"😇", "😡", "🥶", "🤔", "🙌", "🍔",
		"🥦", "🏓", "🥇", "🎸", "🏝", "😪"
	]
	let colorAssetNames: [String] = (1...18).map { "ColorSelect\($0)" }

	private let trackerCategoryStore: TrackerCategoryStore
	private let maxTitleLength = 38
	private let submissionMode: SubmissionMode
	private let stateSubject: CurrentValueSubject<State, Never>
	private let dismissSubject = PassthroughSubject<Void, Never>()
	private let createTrackerSubject = PassthroughSubject<(Tracker, String), Never>()

	private var title = ""
	private var selectedCategoryTitle: String?
	private var selectedEmoji: String?
	private var selectedColorIndex: Int?
	private var selectedSchedule: Set<Weekday> = []

	init(
		mode: TrackerCreationMode,
		trackerCategoryStore: TrackerCategoryStore,
		initialTracker: Tracker? = nil,
		initialCategoryTitle: String? = nil
	) {
		self.mode = mode
		self.trackerCategoryStore = trackerCategoryStore
		if let initialTracker {
			self.submissionMode = .edit(
				originalTrackerID: initialTracker.id,
				createdAt: initialTracker.createdAt,
				isPinned: initialTracker.isPinned
			)
			self.title = initialTracker.title
			self.selectedCategoryTitle = initialCategoryTitle
			self.selectedEmoji = initialTracker.emoji
			self.selectedColorIndex = Self.colorIndex(for: initialTracker.color, in: colorAssetNames)
			self.selectedSchedule = mode.requiresSchedule ? initialTracker.schedule : []
		} else {
			self.submissionMode = .create
			self.title = ""
			self.selectedCategoryTitle = nil
			self.selectedEmoji = nil
			self.selectedColorIndex = nil
			self.selectedSchedule = []
		}
		self.stateSubject = CurrentValueSubject(
			State(
				screenTitle: initialTracker == nil ? mode.screenTitle : mode.editScreenTitle,
				submitButtonTitle: initialTracker == nil
					? String(localized: "common.create")
					: String(localized: "common.save"),
				title: title,
				selectedCategoryTitle: selectedCategoryTitle,
				selectedEmoji: selectedEmoji,
				selectedColorIndex: selectedColorIndex,
				scheduleSummary: mode.requiresSchedule ? Self.scheduleSummary(from: selectedSchedule) : nil,
				isTitleTooLong: title.count > 38,
				isCreateEnabled: false
			)
		)
	}

	func viewDidLoad() {
		emitState()
	}

	func didTapCancel() {
		dismissSubject.send(())
	}

	func didTapCreate() {
		guard let payload = makeCreationPayload() else { return }
		createTrackerSubject.send((payload.tracker, payload.categoryTitle))
		dismissSubject.send(())
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
		let isEditing: Bool
		switch submissionMode {
		case .create:
			isEditing = false
		case .edit:
			isEditing = true
		}

		stateSubject.send(
			State(
				screenTitle: isEditing ? mode.editScreenTitle : mode.screenTitle,
				submitButtonTitle: isEditing
					? String(localized: "common.save")
					: String(localized: "common.create"),
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
		guard
			title.count <= maxTitleLength,
			!normalizedTitle.isEmpty,
			selectedCategoryTitle != nil,
			selectedEmoji != nil,
			selectedColorIndex != nil
		else { return false }

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

		let tracker: Tracker
		switch submissionMode {
		case .create:
			tracker = Tracker(
				title: normalizedTitle,
				emoji: emoji,
				color: color,
				schedule: mode.requiresSchedule ? selectedSchedule : []
			)
		case .edit(let originalTrackerID, let createdAt, let isPinned):
			tracker = Tracker(
				id: originalTrackerID,
				title: normalizedTitle,
				emoji: emoji,
				color: color,
				schedule: mode.requiresSchedule ? selectedSchedule : [],
				createdAt: createdAt,
				isPinned: isPinned
			)
		}
		return (tracker, categoryTitle)
	}

	private var normalizedTitle: String {
		title.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private func scheduleSummary(from selection: Set<Weekday>) -> String {
		Self.scheduleSummary(from: selection)
	}

	private static func scheduleSummary(from selection: Set<Weekday>) -> String {
		if selection.isEmpty { return "" }
		if selection.count == Weekday.allCases.count { return String(localized: "schedule.everyDay") }
		return Weekday.ordered
			.filter { selection.contains($0) }
			.map(\.shortName)
			.joined(separator: ", ")
	}

	private static func colorIndex(for color: UIColor, in colorAssetNames: [String]) -> Int? {
		colorAssetNames.firstIndex { assetName in
			guard let assetColor = UIColor(named: assetName) else { return false }
			return assetColor.isEqual(color)
		}
	}
}
