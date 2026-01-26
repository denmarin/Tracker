//
//  SettingsRowButton.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

/// A simple row-like button with trailing chevron, used for Category / Schedule placeholders.
final class SettingsRowButton: UIControl {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .ypWhite
        layer.cornerRadius = 10
        layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .ypBlack

        valueLabel.font = .systemFont(ofSize: 17)
        valueLabel.textColor = UIColor.ypBlack.withAlphaComponent(0.6)
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        chevron.tintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, chevron])
        stack.isUserInteractionEnabled = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        chevron.widthAnchor.constraint(equalToConstant: 12).isActive = true
    }

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

    func configure(title: String) {
        titleLabel.text = title
    }
    
    func setValueText(_ text: String?) {
        let trimmed = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        valueLabel.text = trimmed.isEmpty ? nil : trimmed
        valueLabel.isHidden = trimmed.isEmpty
    }
}

