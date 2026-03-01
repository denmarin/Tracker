//
//  CategoryListViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//


import UIKit

final class CategoryListViewController: UIViewController {
	var onSelectedCategoryChanged: ((String?) -> Void)?

	private let viewModel: CategoryListViewModel
	private var rows: [CategoryRowViewData] = []

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = String(localized: "category.list.title")
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.rowHeight = 75
		tableView.showsVerticalScrollIndicator = false
		tableView.translatesAutoresizingMaskIntoConstraints = false
		return tableView
	}()

	private let placeholderImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(resource: .trackersPlaceholder)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let placeholderLabel: UILabel = {
		let label = UILabel()
		label.text = String(localized: "category.list.placeholder")
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let placeholderStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let addCategoryButton: UIButton = {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = String(localized: "category.list.add")
		config.baseBackgroundColor = .ypBlack
		config.baseForegroundColor = .ypWhite
		config.background.cornerRadius = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
		button.configuration = config
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	init(viewModel: CategoryListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		nil
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let bottomInset = addCategoryButton.bounds.height + 16
		if tableView.contentInset.bottom != bottomInset {
			tableView.contentInset.bottom = bottomInset
		}
		if tableView.verticalScrollIndicatorInsets.bottom != bottomInset {
			tableView.verticalScrollIndicatorInsets.bottom = bottomInset
		}
	}

	private func setupViews() {
		view.backgroundColor = .ypWhite
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)

		placeholderStack.addArrangedSubview(placeholderImageView)
		placeholderStack.addArrangedSubview(placeholderLabel)

		view.addSubview(titleLabel)
		view.addSubview(tableView)
		view.addSubview(placeholderStack)
		view.addSubview(addCategoryButton)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

			tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 80),

			placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			addCategoryButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16),
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
		])
	}

	private func setupActions() {
		addCategoryButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didTapAddCategory()
		}, for: .touchUpInside)
	}

	private func bindViewModel() {
		viewModel.onRowsChanged = { [weak self] rows in
			self?.rows = rows
			self?.tableView.reloadData()
		}

		viewModel.onEmptyStateChanged = { [weak self] isEmpty in
			self?.placeholderStack.isHidden = !isEmpty
			self?.tableView.isHidden = isEmpty
		}

		viewModel.onSelectedCategoryChanged = { [weak self] selectedCategoryTitle in
			self?.onSelectedCategoryChanged?(selectedCategoryTitle)
		}

		viewModel.onRequestCategoryCreation = { [weak self] in
			self?.presentCategoryCreation()
		}

		viewModel.onRequestCategoryEditing = { [weak self] category in
			self?.presentCategoryEditing(category: category)
		}

		viewModel.onRequestCategoryDeletionConfirmation = { [weak self] in
			self?.presentDeleteConfirmation()
		}

		viewModel.onSelectionConfirmed = { [weak self] in
			self?.navigationController?.popViewController(animated: true)
		}
	}

	private func presentCategoryCreation() {
		let editor = CategoryEditorViewController(
			screenTitle: String(localized: "category.editor.new"),
			initialTitle: nil
		)
		editor.onDone = { [weak self, weak editor] title in
			guard let self else { return true }
			if let errorMessage = self.viewModel.createCategory(title: title) {
				editor?.presentError(message: errorMessage)
				return false
			}
			return true
		}
		navigationController?.pushViewController(editor, animated: true)
	}

	private func presentCategoryEditing(category: TrackerCategoryItem) {
		let editor = CategoryEditorViewController(
			screenTitle: String(localized: "category.editor.edit"),
			initialTitle: category.title
		)
		editor.onDone = { [weak self, weak editor] title in
			guard let self else { return true }
			if let errorMessage = self.viewModel.updateCategory(with: category.objectID, title: title) {
				editor?.presentError(message: errorMessage)
				return false
			}
			return true
		}
		navigationController?.pushViewController(editor, animated: true)
	}

	private func presentDeleteConfirmation() {
		let alert = UIAlertController(
			title: nil,
			message: String(localized: "category.delete.confirm"),
			preferredStyle: .actionSheet
		)

		let deleteAction = UIAlertAction(title: String(localized: "category.delete.action"), style: .destructive) { [weak self] _ in
			guard let self else { return }
			if let errorMessage = self.viewModel.confirmCategoryDeletion() {
				self.presentError(message: errorMessage)
			}
		}
		let cancelAction = UIAlertAction(title: String(localized: "common.cancel"), style: .cancel) { [weak self] _ in
			self?.viewModel.cancelCategoryDeletion()
		}

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		if let popover = alert.popoverPresentationController {
			popover.sourceView = view
			popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 80, width: 1, height: 1)
			popover.permittedArrowDirections = []
		}

		present(alert, animated: true)
	}

	private func presentError(message: String) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: String(localized: "common.ok"), style: .default))
		present(alert, animated: true)
	}
}

extension CategoryListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		rows.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard
			let cell = tableView.dequeueReusableCell(
				withIdentifier: CategoryTableViewCell.reuseIdentifier,
				for: indexPath
			) as? CategoryTableViewCell
		else {
			return UITableViewCell()
		}

		let row = rows[indexPath.row]
		cell.configure(with: row)
		return cell
	}
}

extension CategoryListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		viewModel.didSelectCategory(at: indexPath.row)
	}

	func tableView(
		_ tableView: UITableView,
		contextMenuConfigurationForRowAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
			let editAction = UIAction(title: String(localized: "category.edit.action")) { _ in
				self?.viewModel.didTapEditCategory(at: indexPath.row)
			}

			let deleteAction = UIAction(title: String(localized: "category.delete.action"), attributes: .destructive) { _ in
				self?.viewModel.didTapDeleteCategory(at: indexPath.row)
			}

			return UIMenu(children: [editAction, deleteAction])
		}
	}
}
