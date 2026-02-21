//
//  SettingsRowButton.swift
//  Tracker
//


import UIKit

/// A simple row-like button with trailing chevron, used for Category / Schedule placeholders.
final class SettingsRowButton: UIControl {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(frame: CGRect) {
        super.init(frame: frame)
		backgroundColor = .clear

        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.textColor = .ypBlack

        valueLabel.font = .systemFont(ofSize: 17)
        valueLabel.textColor = UIColor.ypBlack.withAlphaComponent(0.6)
		valueLabel.numberOfLines = 1
		valueLabel.isHidden = true

        chevron.tintColor = UIColor.ypBlack.withAlphaComponent(0.3)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)

		let labelsStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
		labelsStack.axis = .vertical
		labelsStack.spacing = 2
		labelsStack.isUserInteractionEnabled = false
		labelsStack.translatesAutoresizingMaskIntoConstraints = false

		let rowStack = UIStackView(arrangedSubviews: [labelsStack, chevron])
		rowStack.axis = .horizontal
		rowStack.alignment = .center
		rowStack.spacing = 8
		rowStack.isUserInteractionEnabled = false
		rowStack.translatesAutoresizingMaskIntoConstraints = false

		addSubview(rowStack)
		NSLayoutConstraint.activate([
			rowStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
			rowStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
			rowStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
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
		valueLabel.text = trimmed
		valueLabel.isHidden = trimmed.isEmpty
    }
}

