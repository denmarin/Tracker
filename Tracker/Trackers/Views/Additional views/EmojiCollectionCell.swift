//
//  EmojiCollectionCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 31.01.26.
//


import UIKit

final class EmojiCollectionCell: UICollectionViewCell {
    static let reuseId = "EmojiCollectionCell"

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 32)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { nil }

    func configure(emoji: String, isSelected: Bool) {
        label.text = emoji
        // По макету у выбранного emoji появляется светлая плашка
        contentView.backgroundColor = isSelected ? UIColor.ypLightGray : .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.backgroundColor = .clear
        label.text = nil
    }
}
