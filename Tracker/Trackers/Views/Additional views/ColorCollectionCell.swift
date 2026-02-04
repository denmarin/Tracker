//
//  ColorCollectionCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 31.01.26.
//


import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    static let reuseId = "ColorCollectionCell"

	private let outerRingView = UIView()
	private let whiteRingView = UIView()
	private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

		contentView.addSubview(outerRingView)
		contentView.addSubview(whiteRingView)
		contentView.addSubview(colorView)

		[outerRingView, whiteRingView, colorView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
		}

		NSLayoutConstraint.activate([
			outerRingView.widthAnchor.constraint(equalToConstant: 52),
			outerRingView.heightAnchor.constraint(equalToConstant: 52),
			outerRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			outerRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			whiteRingView.widthAnchor.constraint(equalToConstant: 46),
			whiteRingView.heightAnchor.constraint(equalToConstant: 46),
			whiteRingView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			whiteRingView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

			colorView.widthAnchor.constraint(equalToConstant: 40),
			colorView.heightAnchor.constraint(equalToConstant: 40),
			colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
		])

		outerRingView.layer.cornerRadius = 16
		whiteRingView.layer.cornerRadius = 16
		colorView.layer.cornerRadius = 12
		colorView.layer.masksToBounds = true

		outerRingView.layer.borderWidth = 3
		whiteRingView.layer.borderWidth = 3

		outerRingView.isHidden = true
		whiteRingView.isHidden = true
    }

    required init?(coder: NSCoder) { nil }

	func configure(color: UIColor, isSelected: Bool) {
		colorView.backgroundColor = color

		if isSelected {
			outerRingView.isHidden = false
			whiteRingView.isHidden = false

			outerRingView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
			whiteRingView.layer.borderColor = UIColor.ypWhite.cgColor
		} else {
			outerRingView.isHidden = true
			whiteRingView.isHidden = true
		}
	}

    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
