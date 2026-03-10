//
//  TrackersFilterViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 08.03.26.
//

import UIKit

final class TrackersFilterViewController: UIViewController {
	var onSelectFilterOption: ((TrackersFilterOption) -> Void)?

	private let options = TrackersFilterOption.allCases
	private let selectedFilter: TrackersFilter?

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = String(localized: "trackers.filter.title")
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.rowHeight = 75
		tableView.showsVerticalScrollIndicator = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	init(selectedFilter: TrackersFilter?) {
		self.selectedFilter = selectedFilter
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AppAnalytics.shared.open(.filters)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		AppAnalytics.shared.close(.filters)
	}

	private func setupViews() {
		view.backgroundColor = .ypWhite

		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(TrackersFilterOptionCell.self, forCellReuseIdentifier: TrackersFilterOptionCell.reuseIdentifier)

		view.addSubview(titleLabel)
		view.addSubview(tableView)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.heightAnchor.constraint(equalToConstant: CGFloat(options.count) * tableView.rowHeight),
			tableView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}

extension TrackersFilterViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		options.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard
			let cell = tableView.dequeueReusableCell(
				withIdentifier: TrackersFilterOptionCell.reuseIdentifier,
				for: indexPath
			) as? TrackersFilterOptionCell
		else {
			return UITableViewCell()
		}
		let option = options[indexPath.row]
		cell.configure(
			option: option,
			isSelected: option.showsCheckmark(selectedFilter: selectedFilter),
			isFirst: indexPath.row == 0,
			isLast: indexPath.row == options.count - 1
		)
		return cell
	}
}

extension TrackersFilterViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		AppAnalytics.shared.click(.filters, item: .filterOption)
		let option = options[indexPath.row]
		onSelectFilterOption?(option)
		dismiss(animated: true)
	}
}

private final class TrackersFilterOptionCell: UITableViewCell {
	static let reuseIdentifier = "TrackersFilterOptionCell"

	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = .ypBackground
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.textColor = .ypBlack
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let checkmarkView: UIImageView = {
		let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
		imageView.tintColor = .ypBlue
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let separatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.ypBlack.withAlphaComponent(0.1)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupViews()
		setupConstraints()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		titleLabel.text = nil
		checkmarkView.isHidden = true
		separatorView.isHidden = false
		containerView.layer.cornerRadius = 0
		containerView.layer.maskedCorners = []
	}

	func configure(option: TrackersFilterOption, isSelected: Bool, isFirst: Bool, isLast: Bool) {
		titleLabel.text = option.title
		checkmarkView.isHidden = !isSelected
		separatorView.isHidden = isLast
		applyCorners(isFirst: isFirst, isLast: isLast)
	}

	private func setupViews() {
		backgroundColor = .clear
		selectionStyle = .none
		contentView.backgroundColor = .clear

		contentView.addSubview(containerView)
		containerView.addSubview(titleLabel)
		containerView.addSubview(checkmarkView)
		containerView.addSubview(separatorView)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

			titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkView.leadingAnchor, constant: -12),

			checkmarkView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
			checkmarkView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			checkmarkView.widthAnchor.constraint(equalToConstant: 16),
			checkmarkView.heightAnchor.constraint(equalToConstant: 16),

			separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
		])
	}

	private func applyCorners(isFirst: Bool, isLast: Bool) {
		var maskedCorners: CACornerMask = []
		if isFirst {
			maskedCorners.insert(.layerMinXMinYCorner)
			maskedCorners.insert(.layerMaxXMinYCorner)
		}
		if isLast {
			maskedCorners.insert(.layerMinXMaxYCorner)
			maskedCorners.insert(.layerMaxXMaxYCorner)
		}

		containerView.layer.cornerRadius = maskedCorners.isEmpty ? 0 : 16
		containerView.layer.maskedCorners = maskedCorners
	}
}
