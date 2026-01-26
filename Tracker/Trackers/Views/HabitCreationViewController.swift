//
//  HabitCreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class HabitCreationViewController: UIViewController {
    var onCreate: ((Tracker, String) -> Void)?

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
	
	private let categoryRow = SettingsRowButton()
	private let scheduleRow = SettingsRowButton()
	
	private let stack: UIStackView = {
		let s = UIStackView()
		s.axis = .vertical
		s.spacing = 16
		s.translatesAutoresizingMaskIntoConstraints = false
		return s
	}()

    private let titleField: UITextField = {
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
	
    private let bottomBar: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 8
        v.distribution = .fillEqually
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
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

    private var selectedSchedule: Set<Weekday> = []

    override func loadView() {
        self.view = DismissKeyboardView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        navigationItem.title = "Новая привычка"
        setupViews()
		setupConstraints()
		setupActions()
        updateCreateButtonState()
    }

	private func setupViews() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.keyboardDismissMode = .onDrag
		scrollView.alwaysBounceVertical = true
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)

		contentView.addSubview(stack)
		stack.addArrangedSubview(titleField)
		categoryRow.configure(title: "Категория")
		scheduleRow.configure(title: "Расписание")
		scheduleRow.setValueText(scheduleSummary(from: selectedSchedule))
		stack.addArrangedSubview(categoryRow)
		stack.addArrangedSubview(scheduleRow)

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
			let name = (self.titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
			guard !name.isEmpty, !self.selectedSchedule.isEmpty else { return }
			let tracker = Tracker(title: name, emoji: "🙂", color: .systemBlue, schedule: selectedSchedule)
			self.onCreate?(tracker, "Без категории")
			self.navigationController?.dismiss(animated: true)
		}, for: .touchUpInside)

		categoryRow.addAction(UIAction { [weak self] _ in
			self?.presentNotImplementedAlert()
		}, for: .touchUpInside)

		scheduleRow.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			let vc = ScheduleSelectionViewController(initialSelection: self.selectedSchedule)
			vc.onDone = { [weak self] selection in
				guard let self else { return }
				self.selectedSchedule = selection
				self.scheduleRow.setValueText(self.scheduleSummary(from: selection))
				self.updateCreateButtonState()
			}
			self.navigationController?.pushViewController(vc, animated: true)
		}, for: .touchUpInside)

		titleField.addAction(UIAction { [weak self] _ in
			self?.updateCreateButtonState()
		}, for: .editingChanged)
	}

	private func updateCreateButtonState() {
		let hasText = !(titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
		let hasSchedule = !selectedSchedule.isEmpty
		createButton.isEnabled = hasText && hasSchedule
		createButton.setNeedsUpdateConfiguration()
	}

    private func scheduleSummary(from selection: Set<Weekday>) -> String {
        if selection.count == Weekday.allCases.count { return "Каждый день" }
        let items = Weekday.ordered.filter { selection.contains($0) }.map { $0.shortName }
        return items.joined(separator: ", ")
    }

    private func presentNotImplementedAlert() {
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

extension HabitCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

