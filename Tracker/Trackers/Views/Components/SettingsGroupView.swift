//
//  SettingsGroupView.swift
//  Tracker
//



import UIKit

/// Контейнер для нескольких `SettingsRowButton`, чтобы они выглядели как единый блок
/// (как в макете: один белый прямоугольник с разделителями).
final class SettingsGroupView: UIView {

    private let stack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    init(rows: [SettingsRowButton]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .ypBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for (index, row) in rows.enumerated() {
            row.backgroundColor = .clear
            stack.addArrangedSubview(row)
			
            if index < rows.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.ypBlack.withAlphaComponent(0.1)
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale).isActive = true
                stack.addArrangedSubview(separator)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
}
