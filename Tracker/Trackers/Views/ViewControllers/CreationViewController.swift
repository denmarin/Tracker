//
//  CreationViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 25.01.26.
//
//

import UIKit
import Combine

class CreationViewController: UIViewController {
	private let viewModel: CreationViewModel
	private var state: CreationViewModel.State?
	private var cancellables = Set<AnyCancellable>()
	private var scheduleSelectionCancellable: AnyCancellable?

	private lazy var scrollView = UIScrollView()
	private lazy var contentView = UIView()

	private let stack: UIStackView = {
		let s = UIStackView()
		s.axis = .vertical
		s.spacing = 24
		s.translatesAutoresizingMaskIntoConstraints = false
		return s
	}()

	private let headerLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let completedDaysLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 32, weight: .bold)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

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
		tf.placeholder = String(localized: "tracker.creation.name.placeholder")
		tf.backgroundColor = .ypBackground
		tf.layer.cornerRadius = 16
		tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
		tf.leftViewMode = .always
		tf.clearButtonMode = .whileEditing
		tf.returnKeyType = .done
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()

	private let titleErrorLabel: UILabel = {
		let label = UILabel()
		label.text = String(localized: "tracker.creation.name.limit")
		label.textColor = .ypRed
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.textAlignment = .center
		label.isHidden = true
		return label
	}()

	private let cancelButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.bordered()
		config.title = String(localized: "common.cancel")
		config.baseForegroundColor = .ypRed
		config.baseBackgroundColor = .ypWhite
		config.background.backgroundColor = .ypWhite
		config.background.strokeColor = .ypRed
		config.background.strokeWidth = 1
		config.background.cornerRadius = 16
		b.configuration = config
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()

	private let createButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = String(localized: "common.create")
		config.background.cornerRadius = 16
		config.baseBackgroundColor = .ypGray
		config.baseForegroundColor = .ypWhite
		b.configuration = config
		b.isEnabled = false
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()

	private let categoryRow = SettingsRowButton()
	private let scheduleRow = SettingsRowButton()

	private lazy var settingsGroupView: SettingsGroupView = {
		SettingsGroupView(rows: makeSettingsRows())
	}()

	private let emojiTitleLabel: UILabel = {
		let l = UILabel()
		l.text = String(localized: "tracker.creation.emoji.section")
		l.font = .systemFont(ofSize: 19, weight: .bold)
		l.textColor = .ypBlack
		return l
	}()

	private let colorTitleLabel: UILabel = {
		let l = UILabel()
		l.text = String(localized: "tracker.creation.color.section")
		l.font = .systemFont(ofSize: 19, weight: .bold)
		l.textColor = .ypBlack
		return l
	}()

	private lazy var emojiCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 52, height: 52)
		layout.minimumInteritemSpacing = 5
		layout.minimumLineSpacing = 0
		layout.sectionInset = .zero
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.isScrollEnabled = false
		cv.contentInset = .zero
		cv.allowsMultipleSelection = false
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.reuseId)
		cv.dataSource = self
		cv.delegate = self
		return cv
	}()

	private lazy var colorCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: 52, height: 52)
		layout.minimumInteritemSpacing = 5
		layout.minimumLineSpacing = 0
		layout.sectionInset = .zero
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.isScrollEnabled = false
		cv.contentInset = .zero
		cv.allowsMultipleSelection = false
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.reuseId)
		cv.dataSource = self
		cv.delegate = self
		return cv
	}()

	init(viewModel: CreationViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = DismissKeyboardView(frame: .zero)
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
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	private func setupViews() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.keyboardDismissMode = .onDrag
		scrollView.alwaysBounceVertical = true

		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		contentView.addSubview(stack)

		configureSettingsRows()

		stack.addArrangedSubview(headerLabel)
		stack.addArrangedSubview(completedDaysLabel)
		stack.addArrangedSubview(titleField)
		stack.addArrangedSubview(titleErrorLabel)
		stack.addArrangedSubview(settingsGroupView)
		stack.addArrangedSubview(emojiTitleLabel)
		stack.addArrangedSubview(emojiCollectionView)
		stack.addArrangedSubview(colorTitleLabel)
		stack.addArrangedSubview(colorCollectionView)

		titleField.delegate = self

		view.addSubview(bottomBar)
		bottomBar.addArrangedSubview(cancelButton)
		bottomBar.addArrangedSubview(createButton)
	}

	private func configureSettingsRows() {
		categoryRow.configure(title: String(localized: "tracker.creation.category.row"))
		categoryRow.addAction(UIAction { [weak self] _ in
			self?.didTapCategory()
		}, for: .touchUpInside)
		categoryRow.heightAnchor.constraint(equalToConstant: 75).isActive = true

		scheduleRow.configure(title: String(localized: "tracker.creation.schedule.row"))
		scheduleRow.addAction(UIAction { [weak self] _ in
			self?.didTapSchedule()
		}, for: .touchUpInside)
		scheduleRow.heightAnchor.constraint(equalToConstant: 75).isActive = true
	}

	private func makeSettingsRows() -> [SettingsRowButton] {
		var rows = [categoryRow]
		if viewModel.mode.requiresSchedule {
			rows.append(scheduleRow)
		}
		return rows
	}

	private func setupConstraints() {
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

		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
			stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
		])

		headerLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
		completedDaysLabel.heightAnchor.constraint(equalToConstant: 38).isActive = true
		titleField.heightAnchor.constraint(equalToConstant: 75).isActive = true
		titleErrorLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
		emojiCollectionView.heightAnchor.constraint(equalToConstant: 156).isActive = true
		colorCollectionView.heightAnchor.constraint(equalToConstant: 156).isActive = true
		cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
		createButton.heightAnchor.constraint(equalToConstant: 60).isActive = true

		NSLayoutConstraint.activate([
			bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
			bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
			bottomBar.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
		])
	}

	private func setupActions() {
		cancelButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didTapCancel()
		}, for: .touchUpInside)

		createButton.addAction(UIAction { [weak self] _ in
			self?.viewModel.didTapCreate()
		}, for: .touchUpInside)

		titleField.addAction(UIAction { [weak self] _ in
			self?.viewModel.updateTitle(self?.titleField.text ?? "")
		}, for: .editingChanged)
	}

	private func bindViewModel() {
		viewModel.statePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] state in
				self?.applyState(state)
			}
			.store(in: &cancellables)

		viewModel.dismissPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.navigationController?.dismiss(animated: true)
			}
			.store(in: &cancellables)
	}

	private func applyState(_ state: CreationViewModel.State) {
		self.state = state
		headerLabel.text = state.screenTitle
		createButton.configuration?.title = state.submitButtonTitle
		completedDaysLabel.text = state.completedDaysText
		completedDaysLabel.isHidden = state.completedDaysText == nil

		if titleField.text != state.title {
			titleField.text = state.title
		}

		titleErrorLabel.isHidden = !state.isTitleTooLong
		categoryRow.setValueText(state.selectedCategoryTitle)
		scheduleRow.setValueText(state.scheduleSummary)

		createButton.isEnabled = state.isCreateEnabled
		applyCreateButtonStyle(isEnabled: state.isCreateEnabled)
		emojiCollectionView.reloadData()
		colorCollectionView.reloadData()
	}

	private func applyCreateButtonStyle(isEnabled: Bool) {
		guard var config = createButton.configuration else { return }
		let bgColor: UIColor = isEnabled ? .ypBlack : .ypGray

		config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
			bgColor
		}
		config.baseBackgroundColor = bgColor
		config.baseForegroundColor = .ypWhite
		config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
			var outgoing = incoming
			outgoing.foregroundColor = UIColor.ypWhite
			return outgoing
		}
		createButton.configuration = config
	}

	private func didTapCategory() {
		let categoryListViewModel = viewModel.makeCategoryListViewModel()
		let categoryListViewController = CategoryListViewController(viewModel: categoryListViewModel)
		categoryListViewController.onSelectedCategoryChanged = { [weak self] title in
			self?.viewModel.updateSelectedCategory(title: title)
		}
		navigationController?.pushViewController(categoryListViewController, animated: true)
	}

	private func didTapSchedule() {
		guard viewModel.mode.requiresSchedule else { return }

		let scheduleViewModel = ScheduleSelectionViewModel(
			initialSelection: viewModel.currentScheduleSelection()
		)
		scheduleSelectionCancellable = scheduleViewModel.doneSelectionPublisher
			.prefix(1)
			.receive(on: RunLoop.main)
			.sink { [weak self] selection in
				self?.viewModel.updateSchedule(selection)
				self?.scheduleSelectionCancellable = nil
			}

		let scheduleViewController = ScheduleSelectionViewController(viewModel: scheduleViewModel)
		navigationController?.pushViewController(scheduleViewController, animated: true)
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

extension CreationViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

extension CreationViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView === emojiCollectionView { return viewModel.emojis.count }
		return viewModel.colorAssetNames.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		if collectionView === emojiCollectionView {
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: EmojiCollectionCell.reuseId,
				for: indexPath
			) as? EmojiCollectionCell else {
				assertionFailure("Failed to dequeue EmojiCollectionCell")
				return UICollectionViewCell()
			}

			let emoji = viewModel.emojis[indexPath.item]
			let isSelected = emoji == state?.selectedEmoji
			cell.configure(emoji: emoji, isSelected: isSelected)
			return cell
		}

		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: ColorCollectionCell.reuseId,
			for: indexPath
		) as? ColorCollectionCell else {
			assertionFailure("Failed to dequeue ColorCollectionCell")
			return UICollectionViewCell()
		}

		let colorName = viewModel.colorAssetNames[indexPath.item]
		let color = UIColor(named: colorName) ?? .systemBlue
		let isSelected = indexPath.item == state?.selectedColorIndex
		cell.configure(color: color, isSelected: isSelected)
		return cell
	}
}

extension CreationViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView === emojiCollectionView {
			viewModel.selectEmoji(at: indexPath.item)
		} else {
			viewModel.selectColor(at: indexPath.item)
		}
	}
}
