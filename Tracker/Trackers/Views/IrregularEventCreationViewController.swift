//
//  IrregularEventCreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//

import UIKit

final class IrregularEventCreationViewController: UIViewController {
    var onCreate: ((Tracker, String) -> Void)?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let bottomBar: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.spacing = 8
        v.distribution = .fillEqually
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите название трекера"
        tf.backgroundColor = UIColor.secondarySystemBackground
        tf.layer.cornerRadius = 10
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let categoryRow = SettingsRowButton()

    private let cancelButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.bordered()
        config.title = "Отменить"
        config.baseForegroundColor = .systemRed
        b.configuration = config
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let createButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Создать"
        config.baseBackgroundColor = .systemGray3
        config.baseForegroundColor = .white
        b.configuration = config
        b.isEnabled = false
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override func loadView() {
        self.view = DismissKeyboardView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новое нерегулярное событие"
        setup()
        updateCreateButtonState()
    }

    private func setup() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        stack.addArrangedSubview(titleField)
        titleField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        categoryRow.configure(title: "Категория")
        stack.addArrangedSubview(categoryRow)
        
        titleField.delegate = self

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])

        view.addSubview(bottomBar)

        bottomBar.addArrangedSubview(cancelButton)
        bottomBar.addArrangedSubview(createButton)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])

        cancelButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)

        createButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let name = (self.titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { return }
            let tracker = Tracker(title: name, emoji: "🙂", color: .systemBlue, schedule: [])
            self.onCreate?(tracker, "Без категории")
        }, for: .touchUpInside)

        categoryRow.addAction(UIAction { [weak self] _ in
            self?.presentNotImplementedAlert()
        }, for: .touchUpInside)

        titleField.addAction(UIAction { [weak self] _ in
            self?.updateCreateButtonState()
        }, for: .editingChanged)
    }

    private func updateCreateButtonState() {
        let hasText = !(titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        createButton.isEnabled = hasText
        if hasText {
            createButton.configuration?.baseBackgroundColor = .ypBlack
        } else {
            createButton.configuration?.baseBackgroundColor = .systemGray3
        }
    }

    private func presentNotImplementedAlert() {
        let alert = UIAlertController(title: nil, message: "Экран будет реализован позже", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bottom = bottomBar.bounds.height + 16
        if scrollView.contentInset.bottom != bottom {
            scrollView.contentInset.bottom = bottom
        }
        var vInsets = scrollView.verticalScrollIndicatorInsets
        if vInsets.bottom != bottom {
            vInsets.bottom = bottom
            scrollView.verticalScrollIndicatorInsets = vInsets
        }
    }
}
extension IrregularEventCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

