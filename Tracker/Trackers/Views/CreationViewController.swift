//
//  CreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 26.01.26.
//

import UIKit

class TrackerCreationBaseViewController: UIViewController {

	var onCreate: ((Tracker, String) -> Void)?

	// MARK: - UI

	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()

	private let stack: UIStackView = {
		let s = UIStackView()
		s.axis = .vertical
		s.spacing = 16
		s.translatesAutoresizingMaskIntoConstraints = false
		return s
	}()

	private let bottomBar: UIStackView = {
		let v = UIStackView()
		v.axis = .horizontal
		v.spacing = 8
		v.distribution = .fillEqually
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()

	let titleField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите название трекера"
		tf.backgroundColor = .ypWhite
		tf.layer.cornerRadius = 16
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
		tf.leftViewMode = .always
		tf.clearButtonMode = .whileEditing
		tf.returnKeyType = .done
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()

	private let cancelButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.bordered()
		config.title = "Отменить"
		config.baseForegroundColor = .ypRed
		config.background.strokeColor = .ypRed
		config.background.strokeWidth = 1
		config.cornerStyle = .large
		b.configuration = config
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()

	private let createButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = "Создать"
		config.background.cornerRadius = 16
		config.baseBackgroundColor = .ypBlack
		config.baseForegroundColor = .white
		b.configuration = config
		b.isEnabled = false
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()

	// MARK: - Hooks for subclasses
	
	var screenTitle: String { "" }
	
	func makeRows() -> [UIView] { [] }

	func configureTitleFieldAppearance(_ field: UITextField) {}

	func isFormValid(title: String) -> Bool {
		!title.isEmpty
	}

	func makeTracker(title: String) -> Tracker {
		Tracker(title: title, emoji: "🙂", color: .systemBlue, schedule: [])
	}
	
	func selectedCategoryTitle() -> String { "Без категории" }

	// MARK: - Lifecycle

	override func loadView() {
		self.view = DismissKeyboardView(frame: .zero)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBackground
		navigationItem.title = screenTitle

		configureTitleFieldAppearance(titleField)

		setupViews()
		setupConstraints()
		setupActions()

		updateCreateButtonState()
	}

	// MARK: - Setup

	private func setupViews() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.keyboardDismissMode = .onDrag
		scrollView.alwaysBounceVertical = true

		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		contentView.addSubview(stack)

		stack.addArrangedSubview(titleField)

		makeRows().forEach { stack.addArrangedSubview($0) }

		titleField.delegate = self

		view.addSubview(bottomBar)
		bottomBar.addArrangedSubview(cancelButton)
		bottomBar.addArrangedSubview(createButton)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		NSLayoutConstraint.activate([
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
			stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
		])

		titleField.heightAnchor.constraint(equalToConstant: 60).isActive = true
		cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
		createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

		NSLayoutConstraint.activate([
			bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
		])
	}

	private func setupActions() {
		createButton.configurationUpdateHandler = { button in
			guard var config = button.configuration else { return }
			config.baseBackgroundColor = button.isEnabled ? .ypBlack : .ypGray
			config.baseForegroundColor = .ypWhite
			button.configuration = config
		}

		cancelButton.addAction(UIAction { [weak self] _ in
			self?.navigationController?.popViewController(animated: true)
		}, for: .touchUpInside)

		createButton.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			let title = self.currentTitle()
			guard self.isFormValid(title: title) else { return }

			let tracker = self.makeTracker(title: title)
			self.onCreate?(tracker, self.selectedCategoryTitle())
			self.navigationController?.dismiss(animated: true)
		}, for: .touchUpInside)

		titleField.addAction(UIAction { [weak self] _ in
			self?.updateCreateButtonState()
		}, for: .editingChanged)
	}

	// MARK: - Helpers

	func updateCreateButtonState() {
		let title = currentTitle()
		createButton.isEnabled = isFormValid(title: title)
		createButton.setNeedsUpdateConfiguration()
	}

	func currentTitle() -> String {
		(titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
	}

	func presentNotImplementedAlert() {
		let alert = UIAlertController(title: nil, message: "Экран будет реализован позже", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let bottom = bottomBar.bounds.height + 16
		if scrollView.contentInset.bottom != bottom {
			scrollView.contentInset.bottom = bottom
		}
		var vInsets = scrollView.verticalScrollIndicatorInsets
		if vInsets.bottom != bottom {
			vInsets.bottom = bottom
			scrollView.verticalScrollIndicatorInsets = vInsets
		}
	}
}

// MARK: - UITextFieldDelegate
extension TrackerCreationBaseViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
