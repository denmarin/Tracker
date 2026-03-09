//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 17.01.26.
//
//

import UIKit
import Combine

final class StatisticsViewController: UIViewController {
	private let viewModel: StatisticsViewModel
	private var cancellables = Set<AnyCancellable>()

	private enum UIConstants {
		static let sideInset: CGFloat = 16
		static let titleTopInset: CGFloat = 44
		static let contentTopInset: CGFloat = 77
		static let placeholderImageSize: CGFloat = 80
		static let cardsSpacing: CGFloat = 12
		static let cardHeight: CGFloat = 90
	}

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.textColor = .ypBlack
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var statisticsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = UIConstants.cardsSpacing
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

	private lazy var statisticsScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(statisticsStackView)
		return scrollView
	}()

	private let placeholderImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(resource: .statisticsPlaceholder)
		imageView.contentMode = .scaleAspectFit
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	private let placeholderLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .ypBlack
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private lazy var placeholderStack: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [placeholderImageView, placeholderLabel])
		stack.axis = .vertical
		stack.alignment = .center
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	init(viewModel: StatisticsViewModel) {
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
		configureLayout()
		bindViewModel()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AppAnalytics.shared.open(.statistics)
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		AppAnalytics.shared.close(.statistics)
	}

	private func configureLayout() {
		view.addSubview(titleLabel)
		view.addSubview(statisticsScrollView)
		view.addSubview(placeholderStack)

		let safe = view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: UIConstants.titleTopInset),
			titleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: UIConstants.sideInset),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -UIConstants.sideInset)
		])

		NSLayoutConstraint.activate([
			statisticsScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: UIConstants.contentTopInset),
			statisticsScrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: UIConstants.sideInset),
			statisticsScrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -UIConstants.sideInset),
			statisticsScrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor)
		])

		NSLayoutConstraint.activate([
			statisticsStackView.topAnchor.constraint(equalTo: statisticsScrollView.contentLayoutGuide.topAnchor),
			statisticsStackView.leadingAnchor.constraint(equalTo: statisticsScrollView.contentLayoutGuide.leadingAnchor),
			statisticsStackView.trailingAnchor.constraint(equalTo: statisticsScrollView.contentLayoutGuide.trailingAnchor),
			statisticsStackView.bottomAnchor.constraint(equalTo: statisticsScrollView.contentLayoutGuide.bottomAnchor),
			statisticsStackView.widthAnchor.constraint(equalTo: statisticsScrollView.frameLayoutGuide.widthAnchor)
		])

		NSLayoutConstraint.activate([
			placeholderImageView.widthAnchor.constraint(equalToConstant: UIConstants.placeholderImageSize),
			placeholderImageView.heightAnchor.constraint(equalToConstant: UIConstants.placeholderImageSize),
			placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	private func bindViewModel() {
		viewModel.statePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] state in
				self?.apply(state)
			}
			.store(in: &cancellables)
	}

	private func apply(_ state: StatisticsViewModel.State) {
		titleLabel.text = state.title
		placeholderLabel.text = state.emptyMessage

		let isEmpty = state.cards.isEmpty
		placeholderStack.isHidden = !isEmpty
		statisticsScrollView.isHidden = isEmpty

		updateCards(state.cards)
	}

	private func updateCards(_ cards: [StatisticsCardViewData]) {
		statisticsStackView.arrangedSubviews.forEach { view in
			statisticsStackView.removeArrangedSubview(view)
			view.removeFromSuperview()
		}

		for card in cards {
			let cardView = StatisticsCardView()
			cardView.configure(value: card.value, title: card.title)
			statisticsStackView.addArrangedSubview(cardView)
			cardView.heightAnchor.constraint(equalToConstant: UIConstants.cardHeight).isActive = true
		}
	}
}
