	//
	//  CreationViewController.swift
	//  Tracker
	//
	//  Created by Yury Semenyushkin on 26.01.26.
	//

import UIKit

class CreationViewController: UIViewController {
	
	var onCreate: ((Tracker, String) -> Void)?
	var trackerCategoryStore: TrackerCategoryStore?

	private let maxTitleLength = 38
	
		// MARK: - Emoji & Color data
	
	let emojis: [String] = ["🙂","😻","🌺","🐶","❤️","😱",
							"😇","😡","🥶","🤔","🙌","🍔",
							"🥦","🏓","🥇","🎸","🏝","😪"]
	
	let colorAssetNames: [String] = (1...18).map { "ColorSelect\($0)" }
	
	var currentTitle: String {
		(titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
	}
	var selectedEmoji: String?
	var selectedColorIndex: Int?
	
		// MARK: - UI
	
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
	
	private let bottomBar: UIStackView = {
		let v = UIStackView()
		v.axis = .horizontal
		v.spacing = 8
		v.distribution = .fillEqually
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
	
	let titleField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Введите название трекера"
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
		label.text = "Ограничение 38 символов"
		label.textColor = .ypRed
		label.font = .systemFont(ofSize: 17, weight: .regular)
		label.textAlignment = .center
		label.isHidden = true
		return label
	}()
	
	private let cancelButton: UIButton = {
		let b = UIButton(type: .system)
		var config = UIButton.Configuration.bordered()
		config.title = "Отменить"
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
		config.title = "Создать"
		config.background.cornerRadius = 16
		config.baseBackgroundColor = .ypGray
		config.baseForegroundColor = .ypWhite
		b.configuration = config
		b.isEnabled = false
		b.translatesAutoresizingMaskIntoConstraints = false
		return b
	}()
	
	private let categoryRow = SettingsRowButton()
	
	private var selectedCategoryTitleValue: String? {
		didSet {
			categoryRow.setValueText(selectedCategoryTitleValue)
			updateCreateButtonState()
		}
	}
	
	private let emojiTitleLabel: UILabel = {
		let l = UILabel()
		l.text = "Emoji"
		l.font = .systemFont(ofSize: 19, weight: .bold)
		l.textColor = .ypBlack
		return l
	}()
	
	private let colorTitleLabel: UILabel = {
		let l = UILabel()
		l.text = "Цвет"
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
	
		// MARK: - Hooks for subclasses
	
	var screenTitle: String { "" }
	
	func additionalRows() -> [SettingsRowButton] { [] }

	func didTapCategory() {
		guard let categoryStore = resolveCategoryStore() else {
			assertionFailure("TrackerCategoryStore is unavailable")
			return
		}

		let viewModel = CategoryListViewModel(
			categoryStore: categoryStore,
			initiallySelectedCategoryTitle: selectedCategoryTitleValue
		)
		let categoryListViewController = CategoryListViewController(viewModel: viewModel)
		categoryListViewController.onSelectedCategoryChanged = { [weak self] title in
			self?.selectedCategoryTitleValue = title
		}
		navigationController?.pushViewController(categoryListViewController, animated: true)
	}
	
	final func makeRows() -> [UIView] {
		categoryRow.configure(title: "Категория")
		categoryRow.setValueText(selectedCategoryTitleValue)
		categoryRow.addAction(UIAction { [weak self] _ in
			self?.didTapCategory()
		}, for: .touchUpInside)

		let rows = [categoryRow] + additionalRows()
		return [SettingsGroupView(rows: rows)]
	}
	
	func configureTitleFieldAppearance(_ field: UITextField) {}
	
	func isFormValid(title: String, emoji: String?, colorIndex: Int?) -> Bool {
		!title.isEmpty && selectedCategoryTitleValue != nil && emoji != nil && colorIndex != nil
	}
	
	func makeTracker(title: String) -> Tracker {
		let emoji = selectedEmoji ?? "🙂"

		let color: UIColor
		if let index = selectedColorIndex {
			let name = colorAssetNames[index]
			color = UIColor(named: name) ?? .systemBlue
		} else {
			color = .systemBlue
		}

		return Tracker(title: title, emoji: emoji, color: color, schedule: [])
	}
	
	func selectedCategoryTitle() -> String { selectedCategoryTitleValue ?? "" }
	
		// MARK: - Lifecycle
	
	override func loadView() {
		self.view = DismissKeyboardView(frame: .zero)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .ypWhite
		headerLabel.text = screenTitle
		
		configureTitleFieldAppearance(titleField)
		
		setupViews()
		setupConstraints()
		setupActions()
		
		updateCreateButtonState()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
		// MARK: - Setup
	
	private func setupViews() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.keyboardDismissMode = .onDrag
		scrollView.alwaysBounceVertical = true
		
		view.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		contentView.addSubview(stack)
		
		stack.addArrangedSubview(headerLabel)
		stack.addArrangedSubview(titleField)
		stack.addArrangedSubview(titleErrorLabel)
		
		makeRows().forEach { stack.addArrangedSubview($0) }
		
		stack.addArrangedSubview(emojiTitleLabel)
		stack.addArrangedSubview(emojiCollectionView)
		stack.addArrangedSubview(colorTitleLabel)
		stack.addArrangedSubview(colorCollectionView)
		
		titleField.delegate = self
		
		view.addSubview(bottomBar)
		bottomBar.addArrangedSubview(cancelButton)
		bottomBar.addArrangedSubview(createButton)
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
		titleField.heightAnchor.constraint(equalToConstant: 75).isActive = true
		titleErrorLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
		categoryRow.heightAnchor.constraint(equalToConstant: 75).isActive = true
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
			self?.navigationController?.dismiss(animated: true)
		}, for: .touchUpInside)
		
		createButton.addAction(UIAction { [weak self] _ in
			guard let self else { return }
			let title = self.currentTitle
			guard self.isFormValid(title: title, emoji: selectedEmoji, colorIndex: selectedColorIndex) else { return }
			
			let tracker = self.makeTracker(title: title)
			self.onCreate?(tracker, self.selectedCategoryTitle())
			self.navigationController?.dismiss(animated: true)
		}, for: .touchUpInside)
		
		titleField.addAction(UIAction { [weak self] _ in
			self?.updateCreateButtonState()
		}, for: .editingChanged)
	}
	
		// MARK: - Helpers
	
	func updateCreateButtonState() {
		createButton.configurationUpdateHandler = { button in
			guard var config = button.configuration else { return }

			let bgColor: UIColor = button.isEnabled ? .ypBlack : .ypGray

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

			button.configuration = config
		}

		let title = currentTitle
		let hasValidTitleLength = (titleField.text ?? "").count <= maxTitleLength
		titleErrorLabel.isHidden = hasValidTitleLength
		createButton.isEnabled = hasValidTitleLength && isFormValid(title: title, emoji: selectedEmoji, colorIndex: selectedColorIndex)

		createButton.setNeedsUpdateConfiguration()
	}
	
	private func resolveCategoryStore() -> TrackerCategoryStore? {
		if let trackerCategoryStore {
			return trackerCategoryStore
		}

		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return nil
		}

		return TrackerCategoryStore(coreDataStack: appDelegate.coreDataStack)
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

// MARK: - UITextFieldDelegate
extension CreationViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}

// MARK: - UICollectionViewDataSource
extension CreationViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView === emojiCollectionView { return emojis.count }
		return colorAssetNames.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView === emojiCollectionView {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.reuseId, for: indexPath) as? EmojiCollectionCell else {
				assertionFailure("Failed to dequeue EmojiCollectionCell")
				return UICollectionViewCell()
			}
			let emoji = emojis[indexPath.item]
			cell.configure(emoji: emoji, isSelected: emoji == selectedEmoji)
			return cell
		} else {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.reuseId, for: indexPath) as? ColorCollectionCell else {
				assertionFailure("Failed to dequeue ColorCollectionCell")
				return UICollectionViewCell()
			}
			let name = colorAssetNames[indexPath.item]
			let color = UIColor(named: name) ?? .systemBlue
			cell.configure(color: color, isSelected: indexPath.item == selectedColorIndex)
			return cell
		}
	}
}

	// MARK: - UICollectionViewDelegate
extension CreationViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView === emojiCollectionView {
			selectedEmoji = emojis[indexPath.item]
			emojiCollectionView.reloadData()
		} else {
			selectedColorIndex = indexPath.item
			colorCollectionView.reloadData()
		}
		updateCreateButtonState()
	}
}

#Preview {
	CreationViewController()
}
