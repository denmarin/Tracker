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
	private struct EditContext {
		let trackerID: UUID
		let createdAt: Date
		let isPinned: Bool
		let completedCount: Int
	}

	struct State {
		let screenTitle: String
		let submitButtonTitle: String
		let completedDaysText: String?
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
	private static let maxTitleLength = 38
	private let editContext: EditContext?
	private lazy var stateSubject = CurrentValueSubject<State, Never>(makeState())
	private let dismissSubject = PassthroughSubject<Void, Never>()
	private let createTrackerSubject = PassthroughSubject<(Tracker, String), Never>()

	private var title: String
	private var selectedCategoryTitle: String?
	private var selectedEmoji: String?
	private var selectedColorIndex: Int?
	private var selectedSchedule: Set<Weekday>

	init(
		mode: TrackerCreationMode,
		trackerCategoryStore: TrackerCategoryStore,
		initialTracker: Tracker? = nil,
		initialCategoryTitle: String? = nil,
		initialCompletedCount: Int = 0
	) {
		self.mode = mode
		self.trackerCategoryStore = trackerCategoryStore

		let initialEditContext: EditContext?
		let resolvedTitle: String
		let resolvedCategoryTitle: String?
		let resolvedEmoji: String?
		let resolvedColorIndex: Int?
		let resolvedSchedule: Set<Weekday>

		if let initialTracker {
			initialEditContext = EditContext(
				trackerID: initialTracker.id,
				createdAt: initialTracker.createdAt,
				isPinned: initialTracker.isPinned,
				completedCount: initialCompletedCount
			)
			resolvedTitle = initialTracker.title
			resolvedCategoryTitle = initialCategoryTitle
			resolvedEmoji = initialTracker.emoji
			resolvedColorIndex = Self.colorIndex(for: initialTracker.color, in: colorAssetNames)
			resolvedSchedule = mode.requiresSchedule ? initialTracker.schedule : []
		} else {
			initialEditContext = nil
			resolvedTitle = ""
			resolvedCategoryTitle = nil
			resolvedEmoji = nil
			resolvedColorIndex = nil
			resolvedSchedule = []
		}

		self.editContext = initialEditContext
		self.title = resolvedTitle
		self.selectedCategoryTitle = resolvedCategoryTitle
		self.selectedEmoji = resolvedEmoji
		self.selectedColorIndex = resolvedColorIndex
		self.selectedSchedule = resolvedSchedule
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
		stateSubject.send(makeState())
	}

	private func canCreateTracker() -> Bool {
		guard
			title.count <= Self.maxTitleLength,
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
		if let editContext {
			tracker = Tracker(
				id: editContext.trackerID,
				title: normalizedTitle,
				emoji: emoji,
				color: color,
				schedule: mode.requiresSchedule ? selectedSchedule : [],
				createdAt: editContext.createdAt,
				isPinned: editContext.isPinned
			)
		} else {
			tracker = Tracker(
				title: normalizedTitle,
				emoji: emoji,
				color: color,
				schedule: mode.requiresSchedule ? selectedSchedule : []
			)
		}
		return (tracker, categoryTitle)
	}

	private var normalizedTitle: String {
		title.trimmingCharacters(in: .whitespacesAndNewlines)
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

	private var isEditing: Bool {
		editContext != nil
	}

	private var screenTitle: String {
		isEditing ? mode.editScreenTitle : mode.screenTitle
	}

	private var submitButtonTitle: String {
		isEditing ? String(localized: "common.save") : String(localized: "common.create")
	}

	private var completedDaysText: String? {
		Self.makeCompletedDaysText(mode: mode, editContext: editContext)
	}

	private func makeState() -> State {
		State(
			screenTitle: screenTitle,
			submitButtonTitle: submitButtonTitle,
			completedDaysText: completedDaysText,
			title: title,
			selectedCategoryTitle: selectedCategoryTitle,
			selectedEmoji: selectedEmoji,
			selectedColorIndex: selectedColorIndex,
			scheduleSummary: mode.requiresSchedule ? Self.scheduleSummary(from: selectedSchedule) : nil,
			isTitleTooLong: title.count > Self.maxTitleLength,
			isCreateEnabled: canCreateTracker()
		)
	}

	private static func makeCompletedDaysText(
		mode: TrackerCreationMode,
		editContext: EditContext?
	) -> String? {
		guard mode == .habit, let completedCount = editContext?.completedCount else { return nil }
		return TrackerDaysTextFormatter.makeDaysCountText(for: completedCount)
	}
}
