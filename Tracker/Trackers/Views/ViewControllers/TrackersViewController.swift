//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 21.02.26.
//
//

import UIKit
import Combine

final class TrackersViewController: UIViewController {
	private let viewModel: TrackersViewModel
	private var state: TrackersViewModel.State?
	private var sections: [TrackerCategorySectionViewData] = []
	private var cancellables = Set<AnyCancellable>()

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
		label.text = String(localized: "trackers.title")
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let searchBar: UISearchBar = {
		let sb = UISearchBar()
		sb.searchBarStyle = .minimal
		sb.placeholder = String(localized: "trackers.search.placeholder")
		sb.translatesAutoresizingMaskIntoConstraints = false
		return sb
	}()

	private lazy var trackersCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.clipsToBounds = false
		cv.alwaysBounceVertical = true
		cv.showsVerticalScrollIndicator = true
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
		cv.register(
			TrackerSectionHeaderView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
		)
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
		label.text = String(localized: "trackers.placeholder")
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

	private let filtersButton: UIButton = {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = String(localized: "trackers.filter.button")
		config.baseBackgroundColor = .ypBlue
		config.baseForegroundColor = .ypWhite
		config.cornerStyle = .fixed
		config.background.cornerRadius = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
		button.configuration = config
		button.isHidden = true
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	init(viewModel: TrackersViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypWhite

		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateCollectionInsets()
	}

	private func setupViews() {
		view.addSubview(createTrackerButton)
		view.addSubview(datePicker)
		view.addSubview(titleLabel)
		searchBar.delegate = self
		view.addSubview(searchBar)
		view.addSubview(trackersCollectionView)
		view.addSubview(filtersButton)

		placeholderStack.addArrangedSubview(placeholderImageView)
		placeholderStack.addArrangedSubview(placeholderLabel)
		view.addSubview(placeholderStack)
	}

	private func setupConstraints() {
		let safe = view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			createTrackerButton.topAnchor.constraint(equalTo: safe.topAnchor),
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
			filtersButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
			filtersButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -16),
			filtersButton.heightAnchor.constraint(equalToConstant: 50)
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
			self?.viewModel.didTapCreateTracker()
		}, for: .touchUpInside)

		filtersButton.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			self.view.endEditing(true)
			self.presentFilters()
		}, for: .touchUpInside)

		datePicker.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			self.view.endEditing(true)
			self.viewModel.didChangeSelectedDate(self.datePicker.date)
		}, for: .valueChanged)
	}

	private func bindViewModel() {
		viewModel.statePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] state in
				guard let self else { return }
				self.state = state
				self.sections = state.sections
				self.datePicker.setDate(state.selectedDate, animated: false)
				self.filtersButton.isHidden = state.isFilterButtonHidden
				self.trackersCollectionView.reloadData()
				self.updatePlaceholder(with: state.emptyState)
				self.updateCollectionInsets()
			}
			.store(in: &cancellables)

		viewModel.requestTrackerCreationPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.presentTrackerTypeSelection()
			}
			.store(in: &cancellables)

		viewModel.alertPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] alert in
				self?.presentAlert(alert)
			}
			.store(in: &cancellables)
	}

	private func presentFilters() {
		guard let state else { return }
		let filtersViewController = TrackersFiltersViewController(selectedFilter: state.selectedFilter)
		filtersViewController.onSelectFilterOption = { [weak self] option in
			self?.viewModel.didSelectFilterOption(option)
		}

		filtersViewController.modalPresentationStyle = .pageSheet
		if let sheet = filtersViewController.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = false
			if #available(iOS 16.0, *) {
				sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			}
		}

		present(filtersViewController, animated: true)
	}

	private func updateCollectionInsets() {
		let bottomInset = filtersButton.isHidden ? 0 : filtersButton.bounds.height + 24
		if trackersCollectionView.contentInset.bottom != bottomInset {
			trackersCollectionView.contentInset.bottom = bottomInset
		}
		if trackersCollectionView.verticalScrollIndicatorInsets.bottom != bottomInset {
			trackersCollectionView.verticalScrollIndicatorInsets.bottom = bottomInset
		}
	}

	private func presentTrackerTypeSelection() {
		let typeViewModel = viewModel.makeTrackerTypeSelectionViewModel { [weak self] tracker, categoryTitle in
			self?.viewModel.addTracker(tracker, toCategoryWithTitle: categoryTitle)
		}
		let typeViewController = TrackerTypeSelectionViewController(viewModel: typeViewModel)
		let nav = UINavigationController(rootViewController: typeViewController)

		nav.modalPresentationStyle = .pageSheet
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = false
			if #available(iOS 16.0, *) {
				sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			}
		}

		present(nav, animated: true)
	}

	private func presentTrackerEditing(for trackerID: UUID) {
		guard let creationViewModel = viewModel.makeTrackerEditingViewModel(for: trackerID) else { return }

		creationViewModel.createTrackerPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] tracker, categoryTitle in
				self?.viewModel.updateTracker(tracker, toCategoryWithTitle: categoryTitle)
			}
			.store(in: &cancellables)

		let viewController: CreationViewController
		switch creationViewModel.mode {
		case .habit:
			viewController = HabitCreationViewController(viewModel: creationViewModel)
		case .irregularEvent:
			viewController = IrregularEventCreationViewController(viewModel: creationViewModel)
		}

		let nav = UINavigationController(rootViewController: viewController)
		nav.modalPresentationStyle = .pageSheet
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.large()]
			sheet.prefersGrabberVisible = false
			if #available(iOS 16.0, *) {
				sheet.prefersScrollingExpandsWhenScrolledToEdge = false
			}
		}

		present(nav, animated: true)
	}

	private func presentDeleteTrackerConfirmation(for trackerID: UUID) {
		let alert = UIAlertController(
			title: nil,
			message: String(localized: "tracker.delete.confirm"),
			preferredStyle: .actionSheet
		)

		let deleteAction = UIAlertAction(title: String(localized: "tracker.menu.delete"), style: .destructive) { [weak self] _ in
			self?.viewModel.didTapDeleteTracker(for: trackerID)
		}
		let cancelAction = UIAlertAction(title: String(localized: "common.cancel"), style: .cancel)
		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		if let popover = alert.popoverPresentationController {
			popover.sourceView = view
			popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 1, height: 1)
			popover.permittedArrowDirections = []
		}

		present(alert, animated: true)
	}

	private func updatePlaceholder(with emptyState: TrackersViewModel.EmptyState?) {
		guard let emptyState else {
			placeholderStack.isHidden = true
			trackersCollectionView.isHidden = false
			return
		}

		placeholderStack.isHidden = false
		trackersCollectionView.isHidden = true

		switch emptyState {
		case .noTrackers:
			placeholderImageView.image = UIImage(resource: .trackersPlaceholder)
			placeholderLabel.text = String(localized: "trackers.placeholder")
		case .noSearchResults:
			placeholderImageView.image = UIImage(resource: .trackersSearchPlaceholder)
			placeholderLabel.text = String(localized: "trackers.search.empty")
		}
	}

	private func presentAlert(_ alert: TrackersViewModel.Alert) {
		let vc = UIAlertController(
			title: alert.title,
			message: alert.message,
			preferredStyle: .alert
		)
		vc.addAction(UIAlertAction(title: String(localized: "common.ok"), style: .default))
		present(vc, animated: true)
	}
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		sections.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		sections[section].items.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: TrackerCell.reuseIdentifier,
			for: indexPath
		) as? TrackerCell else {
			return UICollectionViewCell()
		}

		let item = sections[indexPath.section].items[indexPath.item]
		cell.configure(
			with: item.tracker,
			isCompleted: item.isCompletedOnSelectedDate,
			completedCount: item.completedCount
		)
		cell.onToggle = { [weak self] in
			self?.viewModel.didTapToggleCompletion(for: item.tracker.id)
		}
		return cell
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		guard
			kind == UICollectionView.elementKindSectionHeader,
			let header = collectionView.dequeueReusableSupplementaryView(
				ofKind: kind,
				withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
				for: indexPath
			) as? TrackerSectionHeaderView
		else {
			return UICollectionReusableView()
		}

		header.configure(title: sections[indexPath.section].title)
		return header
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		referenceSizeForHeaderInSection section: Int
	) -> CGSize {
		CGSize(width: collectionView.bounds.width, height: 32)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let spacing: CGFloat = 9
		let totalSpacing = spacing
		let availableWidth = collectionView.bounds.width - totalSpacing
		let width = floor(availableWidth / 2)
		return CGSize(width: width, height: 148)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumInteritemSpacingForSectionAt section: Int
	) -> CGFloat {
		9
	}

	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		minimumLineSpacingForSectionAt section: Int
	) -> CGFloat {
		12
	}

	func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemAt indexPath: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		let item = sections[indexPath.section].items[indexPath.item]
		return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
			guard let self else { return UIMenu(children: []) }

			let pinActionTitle = item.tracker.isPinned
				? String(localized: "tracker.menu.unpin")
				: String(localized: "tracker.menu.pin")
			let pinAction = UIAction(title: pinActionTitle) { _ in
				self.viewModel.didTapTogglePinned(for: item.tracker.id)
			}

			let editAction = UIAction(title: String(localized: "tracker.menu.edit")) { _ in
				self.presentTrackerEditing(for: item.tracker.id)
			}

			let deleteAction = UIAction(
				title: String(localized: "tracker.menu.delete"),
				attributes: .destructive
			) { _ in
				self.presentDeleteTrackerConfirmation(for: item.tracker.id)
			}

			return UIMenu(children: [pinAction, editAction, deleteAction])
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
	) -> UITargetedPreview? {
		guard
			let indexPath = configuration.identifier as? NSIndexPath,
			let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? TrackerCell
		else {
			return nil
		}
		return cell.makeContextMenuPreview(in: collectionView)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
	) -> UITargetedPreview? {
		guard
			let indexPath = configuration.identifier as? NSIndexPath,
			let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? TrackerCell
		else {
			return nil
		}
		return cell.makeContextMenuPreview(in: collectionView)
	}
}

extension TrackersViewController: UISearchBarDelegate {
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		viewModel.didChangeSearchQuery(searchText)
	}

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		view.endEditing(true)
	}
}
