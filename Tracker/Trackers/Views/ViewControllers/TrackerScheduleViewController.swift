//
//  TrackerScheduleViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//
//

import UIKit
import Combine

final class TrackerScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	private let viewModel: TrackerScheduleViewModel
	private var rows: [TrackerScheduleDayRowViewData] = []
	private var cancellables = Set<AnyCancellable>()

	private let tableView: UITableView = {
		let tv = UITableView(frame: .zero, style: .insetGrouped)
		tv.translatesAutoresizingMaskIntoConstraints = false
		tv.backgroundColor = .clear
		tv.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		tv.rowHeight = 75
		tv.sectionHeaderHeight = 0
		tv.sectionFooterHeight = 0
		tv.showsVerticalScrollIndicator = false
		if #available(iOS 15.0, *) {
			tv.sectionHeaderTopPadding = 0
		}
		return tv
	}()

	private let bottomBar: UIStackView = {
		let v = UIStackView()
		v.axis = .horizontal
		v.spacing = 8
		v.distribution = .fillEqually
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()

	private let doneButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = String(localized: "common.done")
		config.baseBackgroundColor = .ypBlack
		config.baseForegroundColor = .ypWhite
		config.cornerStyle = .large
		b.configuration = config
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()

	init(viewModel: TrackerScheduleViewModel) {
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
		navigationItem.title = String(localized: "schedule.title")
		navigationItem.hidesBackButton = true
		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AppAnalytics.shared.open(.schedule)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		AppAnalytics.shared.close(.schedule)
	}

	private func setupViews() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ScheduleDayCell")
		view.addSubview(tableView)
		view.addSubview(bottomBar)
		bottomBar.addArrangedSubview(doneButton)
		doneButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
		tableView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
		])
	}

	private func setupActions() {
		doneButton.addAction(UIAction { [weak self] _ in
			AppAnalytics.shared.click(.schedule, item: .done)
			self?.viewModel.didTapDone()
		}, for: .touchUpInside)
	}

	private func bindViewModel() {
		viewModel.rowsPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] rows in
				self?.rows = rows
				self?.tableView.reloadData()
			}
			.store(in: &cancellables)

		viewModel.doneSelectionPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.navigationController?.popViewController(animated: true)
			}
			.store(in: &cancellables)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let bottom = bottomBar.bounds.height + 16
		if tableView.contentInset.bottom != bottom {
			tableView.contentInset.bottom = bottom
		}
		var vInsets = tableView.verticalScrollIndicatorInsets
		if vInsets.bottom != bottom {
			vInsets.bottom = bottom
			tableView.verticalScrollIndicatorInsets = vInsets
		}
	}

	func numberOfSections(in tableView: UITableView) -> Int { 1 }

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		rows.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleDayCell", for: indexPath)
		let row = rows[indexPath.row]
		cell.textLabel?.text = row.title
		cell.selectionStyle = .none
		cell.backgroundColor = .ypBackground
		cell.textLabel?.font = .systemFont(ofSize: 17)
		cell.textLabel?.textColor = .ypBlack

		let sw = UISwitch()
		sw.isOn = row.isSelected
		sw.addAction(UIAction { [weak self, weak tableView, weak cell] _ in
			guard
				let self,
				let tableView,
				let cell,
				let currentIndexPath = tableView.indexPath(for: cell)
			else { return }

			AppAnalytics.shared.click(.schedule, item: .day)
			self.viewModel.didToggleDay(at: currentIndexPath.row)
		}, for: .valueChanged)
		cell.accessoryView = sw
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		AppAnalytics.shared.click(.schedule, item: .day)
		viewModel.didToggleDay(at: indexPath.row)
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		.leastNormalMagnitude
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		.leastNormalMagnitude
	}
}
