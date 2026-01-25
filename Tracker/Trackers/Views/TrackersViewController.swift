//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 13.01.26.
//

import UIKit

final class TrackersViewController: UIViewController {
	
	var categories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
	var completedTrackers: [TrackerRecord] = []
	
	private let createTrackerButton: UIButton = {
		let button = UIButton(type: .system)

		var config = UIButton.Configuration.plain()
		config.baseForegroundColor = .ypBlack
		config.contentInsets = .zero
		config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
			pointSize: 19,
			weight: .bold
		)
		config.image = UIImage(systemName: "plus")

		button.configuration = config
		
		button.contentHorizontalAlignment = .center
		button.contentVerticalAlignment = .center

		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.date = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.text = "Трекеры"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.searchBarStyle = .minimal
        sb.placeholder = "Поиск"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
	private lazy var trackersCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.alwaysBounceVertical = true
		cv.showsVerticalScrollIndicator = true
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        cv.register(TrackerSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier)
		cv.dataSource = self
		cv.delegate = self
		return cv
	}()
    
    private let placeholderImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .trackersPlaceholder)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
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
        applyFiltersAndReload()
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
		
        view.addSubview(createTrackerButton)
		
        view.addSubview(datePicker)
		
        view.addSubview(titleLabel)
		
        view.addSubview(searchBar)
		
        view.addSubview(trackersCollectionView)
		
        placeholderStack.addArrangedSubview(placeholderImageView)
        placeholderStack.addArrangedSubview(placeholderLabel)
        view.addSubview(placeholderStack)
	}
	
	private func setupConstraints() {
		let safe = view.safeAreaLayoutGuide
		
		NSLayoutConstraint.activate([
			createTrackerButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 0),
			createTrackerButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
			createTrackerButton.widthAnchor.constraint(equalToConstant: 44),
			createTrackerButton.heightAnchor.constraint(equalToConstant: 44)
		])
		
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: createTrackerButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            datePicker.heightAnchor.constraint(equalToConstant: 34)
        ])
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: createTrackerButton.bottomAnchor, constant: 8),
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
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            trackersCollectionView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
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
		
        datePicker.addAction(UIAction { [weak self] _ in
            self?.didChangeDate()
        }, for: .valueChanged)
	}
	
	private func didTapCreateTracker() {
        let typeVC = TrackerTypeSelectionViewController()
        typeVC.onCreate = { [weak self] tracker, categoryTitle in
            self?.addTracker(tracker, toCategoryWithTitle: categoryTitle)
        }
        let nav = UINavigationController(rootViewController: typeVC)
        present(nav, animated: true)
	}
	
	private func didChangeDate() {
        let dateString = df.string(from: datePicker.date)
        print("didChangeDate: \(dateString)")
        view.endEditing(true)
        applyFiltersAndReload()
	}
    
    // MARK: - Helpers
    private func updatePlaceholderVisibility() {
        let isEmpty = filteredCategories.isEmpty
        placeholderStack.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }

    private func applyFiltersAndReload() {
        let selectedDate = normalizedSelectedDate()
        let weekday = Weekday.from(selectedDate)
        let filtered: [TrackerCategory] = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if !tracker.schedule.isEmpty {
                    let matchesSchedule = tracker.schedule.contains(weekday)
                    return matchesSchedule
                } else {
                    // Irregular case
                    let selectedDay = selectedDate
                    let createdDay = Calendar.current.startOfDay(for: tracker.createdAt)
                    if selectedDay == createdDay {
                        return true
                    }
                    if selectedDay > createdDay {
                        // Show only if not completed on creation day
                        let wasCompletedOnCreationDay = completedTrackers.contains(TrackerRecord(trackerId: tracker.id, date: createdDay))
                        return !wasCompletedOnCreationDay
                    }
                    // Before creation date — never show
                    return false
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        filteredCategories = filtered
        trackersCollectionView.reloadData()
        updatePlaceholderVisibility()
    }

    private func normalizedSelectedDate() -> Date {
        Calendar.current.startOfDay(for: datePicker.date)
    }

    private func isFutureSelectedDate() -> Bool {
        let selected = Calendar.current.startOfDay(for: datePicker.date)
        let today = Calendar.current.startOfDay(for: Date())
        return selected > today
    }

    private func completedCount(for tracker: Tracker) -> Int {
        completedTrackers.filter { $0.trackerId == tracker.id }.count
    }

    private func showFutureDateAlert() {
        let alert = UIAlertController(title: "Нельзя отметить будущее", message: "Выберите сегодняшнюю или прошедшую дату.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
			if category.trackers.contains(where: { $0.id == tracker.id }) {
				hasUpdatedExistingCategory = true
				return category
			}
			let updatedTrackers = category.trackers + [tracker]
			hasUpdatedExistingCategory = true
			return TrackerCategory(title: category.title, trackers: updatedTrackers)
		}
		
		if hasUpdatedExistingCategory {
			categories = newCategories
		} else {
			let newCategory = TrackerCategory(title: title, trackers: [tracker])
			categories = newCategories + [newCategory]
		}
		applyFiltersAndReload()
	}
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategories.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        let isCompleted = isTrackerCompleted(tracker, on: normalizedSelectedDate())
        let count = completedCount(for: tracker)
        cell.configure(with: tracker, isCompleted: isCompleted, completedCount: count)
		cell.onToggle = { [weak self, weak cell] in
			guard
				let self,
				let cell,
				let currentIndexPath = collectionView.indexPath(for: cell)
			else { return }

			if self.isFutureSelectedDate() {
				self.showFutureDateAlert()
				return
			}

			let date = self.normalizedSelectedDate()
			if self.isTrackerCompleted(tracker, on: date) {
				self.unmarkTrackerCompleted(for: tracker, on: date)
			} else {
				self.markTrackerCompleted(for: tracker, on: date)
			}

			collectionView.reloadItems(at: [currentIndexPath])
		}
        return cell
    }

    // Section headers
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier, for: indexPath) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        let title = filteredCategories[indexPath.section].title
        header.configure(title: title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 32)
    }

    // Layout: two columns
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let insets: CGFloat = 0
        let totalSpacing = spacing
        let availableWidth = collectionView.bounds.width - totalSpacing - insets
        let width = floor(availableWidth / 2)
        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        12
    }
}

