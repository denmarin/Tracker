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

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 34, weight: .bold)
		label.textColor = .ypBlack
		label.textAlignment = .left
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let statisticsScrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.showsVerticalScrollIndicator = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()

	private let statisticsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 12
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
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

	private let placeholderStack: UIStackView = {
		let stack = UIStackView()
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
		setupViews()
		setupConstraints()
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

	private func setupViews() {
		view.addSubview(titleLabel)
		view.addSubview(statisticsScrollView)
		statisticsScrollView.addSubview(statisticsStackView)

		placeholderStack.addArrangedSubview(placeholderImageView)
		placeholderStack.addArrangedSubview(placeholderLabel)
		view.addSubview(placeholderStack)
	}

	private func setupConstraints() {
		let safe = view.safeAreaLayoutGuide

		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 44),
			titleLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -16)
		])

		NSLayoutConstraint.activate([
			statisticsScrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
			statisticsScrollView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 16),
			statisticsScrollView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -16),
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
			placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
			placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
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
			cardView.heightAnchor.constraint(equalToConstant: 90).isActive = true
		}
	}
}
