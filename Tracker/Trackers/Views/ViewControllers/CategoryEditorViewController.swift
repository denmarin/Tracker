//
//  CategoryEditorViewController.swift
//  Tracker
//
//

import UIKit

final class CategoryEditorViewController: UIViewController {
	var onDone: ((String) -> Bool)? {
		get { viewModel.onDone }
		set { viewModel.onDone = newValue }
	}

	private let viewModel: CategoryEditorViewModel
	private var state: CategoryEditorViewModel.State?

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let titleTextField: UITextField = {
		let textField = UITextField()
		textField.backgroundColor = .ypBackground
		textField.layer.cornerRadius = 16
		textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		textField.leftViewMode = .always
		textField.clearButtonMode = .whileEditing
		textField.returnKeyType = .done
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()

	private let doneButton: UIButton = {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = "Готово"
		config.baseBackgroundColor = .ypGray
		config.baseForegroundColor = .ypWhite
		config.background.cornerRadius = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
		button.configuration = config
		button.isEnabled = false
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	init(screenTitle: String, initialTitle: String?) {
		self.viewModel = CategoryEditorViewModel(
			screenTitle: screenTitle,
			initialTitle: initialTitle
		)
		super.init(nibName: nil, bundle: nil)
	}

	init(viewModel: CategoryEditorViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

	override func loadView() {
		view = DismissKeyboardView(frame: .zero)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	private func setupViews() {
		view.backgroundColor = .ypWhite
		view.addSubview(titleLabel)
		view.addSubview(titleTextField)
		view.addSubview(doneButton)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
			titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			titleTextField.heightAnchor.constraint(equalToConstant: 75),

			doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			doneButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
			doneButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}

	private func setupActions() {
		titleTextField.delegate = self
		titleTextField.placeholder = "Введите название категории"
		titleTextField.addAction(UIAction { [weak self] _ in
			self?.viewModel.updateInputTitle(self?.titleTextField.text ?? "")
		}, for: .editingChanged)

		doneButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didTapDone()
		}, for: .touchUpInside)
	}

	private func bindViewModel() {
		viewModel.onStateChanged = { [weak self] state in
			self?.applyState(state)
		}
		viewModel.onCloseRequested = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
	}

	private func applyState(_ state: CategoryEditorViewModel.State) {
		self.state = state
		titleLabel.text = state.screenTitle
		if titleTextField.text != state.inputTitle {
			titleTextField.text = state.inputTitle
		}
		doneButton.isEnabled = state.isDoneEnabled
		applyDoneButtonStyle(isEnabled: state.isDoneEnabled)
	}

	private func applyDoneButtonStyle(isEnabled: Bool) {
		guard var config = doneButton.configuration else { return }
		let backgroundColor: UIColor = isEnabled ? .ypBlack : .ypGray
		config.baseBackgroundColor = backgroundColor
		config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
			backgroundColor
		}
		doneButton.configuration = config
	}

	func presentError(message: String) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}
}

extension CategoryEditorViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		viewModel.didTapReturn()
		if state?.isDoneEnabled != true {
			textField.resignFirstResponder()
		}
		return true
	}
}
