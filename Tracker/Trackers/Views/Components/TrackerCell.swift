//
//  TrackerCell.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 23.01.26.
//

import UIKit

final class TrackerCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"

    var onToggle: (() -> Void)?

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiBadgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.ypWhite.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.addSubview(emojiBadgeView)
        emojiBadgeView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)

        contentView.addSubview(countLabel)
        contentView.addSubview(toggleButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBadgeView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBadgeView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBadgeView.widthAnchor.constraint(equalToConstant: 24),
            emojiBadgeView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBadgeView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBadgeView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            toggleButton.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 34),
            toggleButton.heightAnchor.constraint(equalToConstant: 34)
        ])

        toggleButton.addAction(UIAction { [weak self] _ in
            self?.onToggle?()
        }, for: .touchUpInside)
    }

    func configure(with tracker: Tracker, isCompleted: Bool, completedCount: Int) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        countLabel.text = "\(completedCount) \(localizedDayWord(for: completedCount))"

        let imageName = isCompleted ? "checkmark" : "plus"
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        toggleButton.setImage(image, for: .normal)
        toggleButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color

        contentView.alpha = 1
    }

    private func localizedDayWord(for count: Int) -> String {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
        if languageCode == "ru" {
            let mod10 = count % 10
            let mod100 = count % 100
            if mod10 == 1 && mod100 != 11 {
                return String(localized: "tracker.dayWord.one")
            }
            if (2...4).contains(mod10) && !(12...14).contains(mod100) {
                return String(localized: "tracker.dayWord.few")
            }
            return String(localized: "tracker.dayWord.many")
        }

        return count == 1
            ? String(localized: "tracker.dayWord.one")
            : String(localized: "tracker.dayWord.other")
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
