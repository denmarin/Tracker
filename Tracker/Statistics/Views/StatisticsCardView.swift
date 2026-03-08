//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Codex on 08.03.26.
//

import UIKit

final class StatisticsCardView: UIView {
	private enum UIConstants {
		static let cornerRadius: CGFloat = 16
		static let borderWidth: CGFloat = 1
		static let horizontalInset: CGFloat = 12
		static let topInset: CGFloat = 12
		static let verticalSpacing: CGFloat = 7
	}

	private let valueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.textColor = .ypBlack
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .ypBlack
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let gradientBorderLayer = CAGradientLayer()
	private let borderMaskLayer = CAShapeLayer()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupAppearance()
		setupSubviews()
		setupConstraints()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		gradientBorderLayer.frame = bounds

		let outerPath = UIBezierPath(
			roundedRect: bounds,
			cornerRadius: UIConstants.cornerRadius
		)
		let innerRect = bounds.insetBy(dx: UIConstants.borderWidth, dy: UIConstants.borderWidth)
		let innerPath = UIBezierPath(
			roundedRect: innerRect,
			cornerRadius: max(UIConstants.cornerRadius - UIConstants.borderWidth, 0)
		)
		outerPath.append(innerPath)

		borderMaskLayer.path = outerPath.cgPath
		borderMaskLayer.fillRule = .evenOdd
	}

	func configure(value: String, title: String) {
		valueLabel.text = value
		titleLabel.text = title
	}

	private func setupAppearance() {
		backgroundColor = .ypWhite
		layer.cornerRadius = UIConstants.cornerRadius
		layer.masksToBounds = true

		gradientBorderLayer.colors = [
			UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1).cgColor,
			UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1).cgColor,
			UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1).cgColor
		]
		gradientBorderLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientBorderLayer.endPoint = CGPoint(x: 1, y: 0.5)
		gradientBorderLayer.mask = borderMaskLayer
		layer.addSublayer(gradientBorderLayer)
	}

	private func setupSubviews() {
		addSubview(valueLabel)
		addSubview(titleLabel)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: UIConstants.topInset),
			valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.horizontalInset),
			valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -UIConstants.horizontalInset),

			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UIConstants.horizontalInset),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -UIConstants.horizontalInset),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -UIConstants.topInset),
			titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: UIConstants.verticalSpacing)
		])
	}
}
