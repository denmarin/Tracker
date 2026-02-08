//
//  ColorCollectionCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 31.01.26.
//


import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    static let reuseId = "ColorCollectionCell"

	private let selectionOuterView = UIView()
	private let selectionInnerView = UIView()
	private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

		contentView.addSubview(selectionOuterView)
		contentView.addSubview(selectionInnerView)
		contentView.addSubview(colorView)

		[selectionOuterView, selectionInnerView, colorView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

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
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])

		selectionOuterView.layer.cornerRadius = 16
		selectionInnerView.layer.cornerRadius = 14
		selectionInnerView.backgroundColor = .ypWhite
		colorView.layer.cornerRadius = 12
		colorView.layer.masksToBounds = true

		selectionOuterView.isHidden = true
		selectionInnerView.isHidden = true
    }

    required init?(coder: NSCoder) { nil }

	func configure(color: UIColor, isSelected: Bool) {
		colorView.backgroundColor = color

		if isSelected {
			selectionOuterView.isHidden = false
			selectionInnerView.isHidden = false
			selectionOuterView.backgroundColor = color.withAlphaComponent(0.3)
		} else {
			selectionOuterView.isHidden = true
			selectionInnerView.isHidden = true
		}
	}

    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
