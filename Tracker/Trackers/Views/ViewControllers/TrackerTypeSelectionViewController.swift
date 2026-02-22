//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//
//

import UIKit
import Combine

final class TrackerTypeSelectionViewController: UIViewController {
	private let viewModel: TrackerTypeSelectionViewModel
	private var cancellables = Set<AnyCancellable>()

	private let stack: UIStackView = {
		let s = UIStackView()
		s.axis = .vertical
		s.spacing = 16
		s.translatesAutoresizingMaskIntoConstraints = false
		return s
	}()

	private lazy var habitButton: UIButton = makePrimaryButton(title: "Привычка")
	private lazy var irregularButton: UIButton = makePrimaryButton(title: "Нерегулярное событие")

	init(viewModel: TrackerTypeSelectionViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypWhite
		navigationItem.title = "Создание трекера"
		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	private func setupViews() {
		view.addSubview(stack)
		stack.addArrangedSubview(habitButton)
		stack.addArrangedSubview(irregularButton)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	private func setupActions() {
		habitButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didSelectHabit()
		}, for: .touchUpInside)

		irregularButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didSelectIrregularEvent()
		}, for: .touchUpInside)
	}

	private func bindViewModel() {
		viewModel.routeToCreationPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] creationViewModel in
				guard let self else { return }
				let viewController: CreationViewController
				switch creationViewModel.mode {
				case .habit:
					viewController = HabitCreationViewController(viewModel: creationViewModel)
				case .irregularEvent:
					viewController = IrregularEventCreationViewController(viewModel: creationViewModel)
				}
				self.navigationController?.pushViewController(viewController, animated: true)
			}
			.store(in: &cancellables)
	}

	private func makePrimaryButton(title: String) -> UIButton {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = title
		config.baseBackgroundColor = .ypBlack
		config.baseForegroundColor = .ypWhite
		config.cornerStyle = .large
		config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
		button.configuration = config
		button.layer.cornerRadius = 16
		button.layer.masksToBounds = true
		button.translatesAutoresizingMaskIntoConstraints = false
		button.heightAnchor.constraint(equalToConstant: 60).isActive = true
		return button
	}
}
