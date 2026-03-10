//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 08.03.26.
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

	private let gradientBorderView = GradientBorderView()
	private let contentContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = .ypWhite
		view.layer.cornerRadius = UIConstants.cornerRadius - UIConstants.borderWidth
		view.layer.masksToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

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

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureAppearance()
		configureLayout()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(value: String, title: String) {
		valueLabel.text = value
		titleLabel.text = title
	}

	private func configureAppearance() {
		layer.cornerRadius = UIConstants.cornerRadius
		layer.masksToBounds = true
	}

	private func configureLayout() {
		gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientBorderView)
		gradientBorderView.addSubview(contentContainerView)
		contentContainerView.addSubview(valueLabel)
		contentContainerView.addSubview(titleLabel)

		NSLayoutConstraint.activate([
			gradientBorderView.topAnchor.constraint(equalTo: topAnchor),
			gradientBorderView.leadingAnchor.constraint(equalTo: leadingAnchor),
			gradientBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
			gradientBorderView.bottomAnchor.constraint(equalTo: bottomAnchor),

			contentContainerView.topAnchor.constraint(equalTo: gradientBorderView.topAnchor, constant: UIConstants.borderWidth),
			contentContainerView.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: UIConstants.borderWidth),
			contentContainerView.trailingAnchor.constraint(equalTo: gradientBorderView.trailingAnchor, constant: -UIConstants.borderWidth),
			contentContainerView.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor, constant: -UIConstants.borderWidth),

			valueLabel.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: UIConstants.topInset),
			valueLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: UIConstants.horizontalInset),
			valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor, constant: -UIConstants.horizontalInset),

			titleLabel.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: UIConstants.horizontalInset),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor, constant: -UIConstants.horizontalInset),
			titleLabel.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -UIConstants.topInset),
			titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: UIConstants.verticalSpacing)
		])
	}
}

private final class GradientBorderView: UIView {
	override class var layerClass: AnyClass { CAGradientLayer.self }

	override init(frame: CGRect) {
		super.init(frame: frame)
		configureGradientLayer()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func configureGradientLayer() {
		guard let gradientLayer = layer as? CAGradientLayer else { return }
		gradientLayer.colors = [
			UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1).cgColor,
			UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1).cgColor,
			UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1).cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
	}
}
