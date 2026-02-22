//
//  CategoryEditorViewModel.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//

import Foundation

final class CategoryEditorViewModel {
	struct State {
		let screenTitle: String
		let inputTitle: String
		let isDoneEnabled: Bool
	}

	var onStateChanged: ((State) -> Void)?
	var onDone: ((String) -> Bool)?
	var onCloseRequested: (() -> Void)?

	private let screenTitle: String
	private var inputTitle: String

	init(screenTitle: String, initialTitle: String?) {
		self.screenTitle = screenTitle
		self.inputTitle = initialTitle ?? ""
	}

	func viewDidLoad() {
		emitState()
	}

	func updateInputTitle(_ value: String) {
		inputTitle = value
		emitState()
	}

	func didTapDone() {
		let title = normalizedInputTitle()
		guard !title.isEmpty else { return }
		let shouldClose = onDone?(title) ?? true
		if shouldClose {
			onCloseRequested?()
		}
	}

	func didTapReturn() {
		guard canSubmit else { return }
		didTapDone()
	}

	private var canSubmit: Bool {
		!normalizedInputTitle().isEmpty
	}

	private func emitState() {
		onStateChanged?(
			State(
				screenTitle: screenTitle,
				inputTitle: inputTitle,
				isDoneEnabled: canSubmit
			)
		)
	}

	private func normalizedInputTitle() -> String {
		inputTitle.trimmingCharacters(in: .whitespacesAndNewlines)
	}
}
