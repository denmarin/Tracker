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

    private let pinImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let imageView = UIImageView(image: UIImage(systemName: "pin.fill", withConfiguration: config))
        imageView.tintColor = .ypWhite
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(emojiBadgeView)
        emojiBadgeView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(pinImageView)

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

            pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pinImageView.widthAnchor.constraint(equalToConstant: 12),
            pinImageView.heightAnchor.constraint(equalToConstant: 12),

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

    func makeContextMenuPreview(in container: UIView) -> UITargetedPreview {
        let snapshotView = cardView.snapshotView(afterScreenUpdates: false) ?? UIView(frame: cardView.bounds)
        snapshotView.frame = cardView.bounds
        snapshotView.layer.cornerRadius = cardView.layer.cornerRadius
        snapshotView.layer.masksToBounds = true
        if let cardBackgroundColor = cardView.backgroundColor {
            snapshotView.backgroundColor = cardBackgroundColor
        }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        parameters.visiblePath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        )
        parameters.shadowPath = parameters.visiblePath

        let center = cardView.convert(
            CGPoint(x: cardView.bounds.midX, y: cardView.bounds.midY),
            to: container
        )
        let target = UIPreviewTarget(
            container: container,
            center: center,
            transform: .identity
        )
        return UITargetedPreview(view: snapshotView, parameters: parameters, target: target)
    }

    func configure(with tracker: Tracker, isCompleted: Bool, completedCount: Int) {
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        pinImageView.isHidden = !tracker.isPinned
        countLabel.text = TrackerDaysTextFormatter.makeDaysCountText(for: completedCount)

        let imageName = isCompleted ? "checkmark" : "plus"
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfig)
        toggleButton.setImage(image, for: .normal)
        toggleButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color

        contentView.alpha = 1
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
