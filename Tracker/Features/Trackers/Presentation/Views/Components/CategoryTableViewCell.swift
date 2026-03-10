//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//


import UIKit
import CoreData

struct CategoryRowViewData: Equatable {
	let objectID: NSManagedObjectID
	let title: String
	let isSelected: Bool
	let isFirst: Bool
	let isLast: Bool
}

final class CategoryTableViewCell: UITableViewCell {
	static let reuseIdentifier = "CategoryTableViewCell"

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

	func configure(with viewData: CategoryRowViewData) {
		titleLabel.text = viewData.title
		checkmarkView.isHidden = !viewData.isSelected
		separatorView.isHidden = viewData.isLast
		applyCorners(isFirst: viewData.isFirst, isLast: viewData.isLast)
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
