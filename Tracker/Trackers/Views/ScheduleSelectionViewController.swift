//
//  ScheduleSelectionViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class ScheduleSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var onDone: ((Set<Weekday>) -> Void)?

    private var selection: Set<Weekday>
    private let daysOrder: [Weekday] = Weekday.ordered

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
        config.title = "Готово"
        config.baseBackgroundColor = .ypBlack
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        b.configuration = config
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    init(initialSelection: Set<Weekday>) {
        self.selection = initialSelection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.selection = []
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        navigationItem.title = "Расписание"
        setupViews()
        setupConstraints()
        setupActions()
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
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
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -8),

            bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
    }

    private func setupActions() {
        doneButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onDone?(self.selection)
            self.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
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

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        daysOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let day = daysOrder[indexPath.row]
        cell.textLabel?.text = fullName(for: day)
        cell.selectionStyle = .none
        cell.backgroundColor = .ypWhite
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = .ypBlack

        let sw = UISwitch()
        sw.isOn = selection.contains(day)
        sw.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if sw.isOn { self.selection.insert(day) } else { self.selection.remove(day) }
        }, for: .valueChanged)
        cell.accessoryView = sw
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sw = tableView.cellForRow(at: indexPath)?.accessoryView as? UISwitch else { return }
        sw.setOn(!sw.isOn, animated: true)
        let day = daysOrder[indexPath.row]
        if sw.isOn { selection.insert(day) } else { selection.remove(day) }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { .leastNormalMagnitude }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }

    // MARK: - Helpers
    private func fullName(for day: Weekday) -> String {
        return day.fullName
    }
}

