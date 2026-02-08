//
//  EmojiCollectionCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 31.01.26.
//


import UIKit

final class EmojiCollectionCell: UICollectionViewCell {

	static let reuseId = "EmojiCollectionCell"

	// MARK: - Views

	private let label: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 32)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	// MARK: - Init

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupContentView()
		setupViews()
		setupConstraints()
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
		contentView.addSubview(label)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}

	// MARK: - Public

	func configure(emoji: String, isSelected: Bool) {
		label.text = emoji
		contentView.backgroundColor = isSelected ? .ypLightGray : .clear
	}

	// MARK: - Reuse

	override func prepareForReuse() {
		super.prepareForReuse()
		label.text = nil
		contentView.backgroundColor = .clear
	}
}
