//
//  TrackerTypeSelectionViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {
    // Callback to bubble creation up to the presenter
    var onCreate: ((Tracker, String) -> Void)?
	var trackerCategoryStore: TrackerCategoryStore?

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 16
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    private lazy var habitButton: UIButton = makePrimaryButton(title: "Привычка")
    private lazy var irregularButton: UIButton = makePrimaryButton(title: "Нерегулярное событие")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationItem.title = "Создание трекера"
        setupViews()
        setupConstraints()
        setupActions()
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
			guard let self else { return }
			let vc = HabitCreationViewController()
			vc.trackerCategoryStore = self.trackerCategoryStore
			vc.onCreate = { [weak self] tracker, category in
				self?.onCreate?(tracker, category)
			}
			self.navigationController?.pushViewController(vc, animated: true)
		}, for: .touchUpInside)

		irregularButton.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			let vc = IrregularEventCreationViewController()
			vc.trackerCategoryStore = self.trackerCategoryStore
			vc.onCreate = { [weak self] tracker, category in
				self?.onCreate?(tracker, category)
			}
			self.navigationController?.pushViewController(vc, animated: true)
		}, for: .touchUpInside)
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
