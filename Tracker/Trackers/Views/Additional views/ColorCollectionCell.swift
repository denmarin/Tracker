//
//  ColorCollectionCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 31.01.26.
//


import UIKit

final class ColorCollectionCell: UICollectionViewCell {

	static let reuseId = "ColorCollectionCell"

	// MARK: - Views

	private let selectionOuterView = UIView()
	private let selectionInnerView = UIView()
	private let colorView = UIView()

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupContentView()
		setupViews()
		setupConstraints()
		setupAppearance()
	}

	required init?(coder: NSCoder) {
		nil
	}

	// MARK: - Setup

	private func setupContentView() {
		contentView.layer.cornerRadius = 16
		contentView.layer.masksToBounds = true
	}

	private func setupViews() {
		[selectionOuterView, selectionInnerView, colorView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview($0)
		}
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			selectionOuterView.widthAnchor.constraint(equalToConstant: 52),
			selectionOuterView.heightAnchor.constraint(equalToConstant: 52),
			selectionOuterView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			selectionOuterView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			selectionInnerView.widthAnchor.constraint(equalToConstant: 46),
			selectionInnerView.heightAnchor.constraint(equalToConstant: 46),
			selectionInnerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			selectionInnerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			colorView.widthAnchor.constraint(equalToConstant: 40),
			colorView.heightAnchor.constraint(equalToConstant: 40),
			colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	private func setupAppearance() {
		selectionOuterView.layer.cornerRadius = 16
		selectionInnerView.layer.cornerRadius = 14
		selectionInnerView.backgroundColor = .ypWhite

		colorView.layer.cornerRadius = 12
		colorView.layer.masksToBounds = true

		selectionOuterView.isHidden = true
		selectionInnerView.isHidden = true
	}

	// MARK: - Public

	func configure(color: UIColor, isSelected: Bool) {
		colorView.backgroundColor = color
		selectionOuterView.isHidden = !isSelected
		selectionInnerView.isHidden = !isSelected
		selectionOuterView.backgroundColor = isSelected
			? color.withAlphaComponent(0.3)
			: nil
	}

	// MARK: - Reuse

	override func prepareForReuse() {
		super.prepareForReuse()
		colorView.backgroundColor = nil
	}
}
