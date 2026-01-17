//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 13.01.26.
//

import UIKit

final class TrackersViewController: UIViewController {
	
	var categories: [TrackerCategory] = []
	var completedTrackers: [TrackerRecord] = []
	
	private let createTrackerButton = UIButton()
	private let dateButton = UIButton()
	private let titleLabel = UILabel()
	private let searchBar = UISearchBar()
	private let placeholderImageView = UIImageView()
	private let placeholderLabel = UILabel()
	private let placeholderStack = UIStackView()
	
	private lazy var df: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yy"
		return formatter
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypBackground
		
		setupViews()
		setupConstraints()
		setupActions()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	private func setupViews() {
		
		var addButtonConfig = UIButton.Configuration.plain()
		addButtonConfig.image = UIImage(systemName: "plus")
		addButtonConfig.baseForegroundColor = .ypBlack
		addButtonConfig.contentInsets = .zero
		createTrackerButton.configuration = addButtonConfig
		createTrackerButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(createTrackerButton)
		
		var dateButtonConfig = UIButton.Configuration.filled()
		dateButtonConfig.baseBackgroundColor = .secondarySystemBackground
		dateButtonConfig.baseForegroundColor = .ypBlack
		dateButtonConfig.cornerStyle = .capsule
		dateButtonConfig.contentInsets = .init(top: 5.5, leading: 6, bottom: 5.5, trailing: 6)
		dateButtonConfig.title = df.string(from: Date())
		dateButtonConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
			var newAttributes = attributes
			newAttributes.font = .systemFont(ofSize: 17)
			return newAttributes
		}
		dateButton.configuration = dateButtonConfig
		dateButton.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(dateButton)
		
		titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
		titleLabel.text = "Трекеры"
		titleLabel.textAlignment = .left
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(titleLabel)
		
		searchBar.searchBarStyle = .minimal
		searchBar.placeholder = "Поиск"
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(searchBar)
		
		placeholderImageView.image = UIImage(resource: .trackersPlaceholder)
		placeholderImageView.contentMode = .scaleAspectFit
		placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
		
		placeholderLabel.text = "Что будем отслеживать?"
		placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
		placeholderLabel.textColor = .ypBlack
		placeholderLabel.textAlignment = .center
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
		
		placeholderStack.axis = .vertical
		placeholderStack.alignment = .center
		placeholderStack.spacing = 8
		placeholderStack.translatesAutoresizingMaskIntoConstraints = false
		placeholderStack.addArrangedSubview(placeholderImageView)
		placeholderStack.addArrangedSubview(placeholderLabel)
		view.addSubview(placeholderStack)
	}
	
	private func setupConstraints() {
		let safe = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			createTrackerButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 0),
			createTrackerButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 8),
			createTrackerButton.widthAnchor.constraint(equalToConstant: 44),
			createTrackerButton.heightAnchor.constraint(equalToConstant: 44)
		])
		
		NSLayoutConstraint.activate([
			dateButton.centerYAnchor.constraint(equalTo: createTrackerButton.centerYAnchor),
			dateButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
			dateButton.heightAnchor.constraint(equalToConstant: 34)
		])
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: createTrackerButton.bottomAnchor, constant: 0),
			titleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -16)
		])
		
		NSLayoutConstraint.activate([
			searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			searchBar.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
			searchBar.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
			searchBar.heightAnchor.constraint(equalToConstant: 36)
		])
		
		NSLayoutConstraint.activate([
			placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 80)
		])
		
		NSLayoutConstraint.activate([
			placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}
	
	private func setupActions() {
		createTrackerButton.addAction(UIAction { [weak self] _ in
			self?.didTapCreateTracker()
		}, for: .touchUpInside)
		
		dateButton.addAction(UIAction { [weak self] _ in
			self?.didTapDate()
		}, for: .touchUpInside)
	}
	
	private func didTapCreateTracker() {
		print("didTapAdd")
	}
	
	private func didTapDate() {
		print("didTapDate")
	}
	
	// MARK: - Completion management

	func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
		completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: date))
	}
	func markTrackerCompleted(for tracker: Tracker, on date: Date) {
		let record = TrackerRecord(trackerId: tracker.id, date: date)
		if !completedTrackers.contains(record) {
			completedTrackers.append(record)
		}
	}

	func unmarkTrackerCompleted(for tracker: Tracker, on date: Date) {
		let key = TrackerRecord(trackerId: tracker.id, date: date)
		if let index = completedTrackers.firstIndex(of: key) {
			completedTrackers.remove(at: index)
		}
	}

	// MARK: - Category management (immutable updates)
	/// Добавить трекер в категорию по заголовку, создавая новые копии структур и массивов.
	/// Если категории с таким заголовком нет, будет создана новая категория в конце списка.
	func addTracker(_ tracker: Tracker, toCategoryWithTitle title: String) {
		var hasUpdatedExistingCategory = false
		let newCategories: [TrackerCategory] = categories.map { category in
			guard category.title == title else { return category }
			// Если трекер уже есть в категории — возвращаем категорию без изменений
			if category.trackers.contains(where: { $0.id == tracker.id }) {
				hasUpdatedExistingCategory = true
				return category
			}
			let updatedTrackers = category.trackers + [tracker]
			hasUpdatedExistingCategory = true
			return TrackerCategory(title: category.title, trackers: updatedTrackers)
		}
		// Если категория найдена и обновлена — присваиваем новый список
		if hasUpdatedExistingCategory {
			categories = newCategories
		} else {
			// Иначе создаём новую категорию и формируем новый список
			let newCategory = TrackerCategory(title: title, trackers: [tracker])
			categories = newCategories + [newCategory]
		}
	}
}

