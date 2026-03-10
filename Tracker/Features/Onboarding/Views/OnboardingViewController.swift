//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Yury Semenyushkin on 19.02.26.
//
//

import UIKit
import Combine

final class OnboardingViewController: UIViewController {
	var onFinish: (() -> Void)?

	private let viewModel: OnboardingViewModel
	private var cancellables = Set<AnyCancellable>()

	private lazy var pageViewController: UIPageViewController = {
		let vc = UIPageViewController(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal
		)
		vc.dataSource = self
		vc.delegate = self
		return vc
	}()

	private lazy var pageViewControllers: [OnboardingPageContentViewController] = {
		viewModel.pages.map { page in
			OnboardingPageContentViewController(page: page)
		}
	}()

	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.numberOfPages = 0
		control.currentPage = 0
		control.currentPageIndicatorTintColor = .ypFixedBlack
		control.pageIndicatorTintColor = .ypFixedBlack.withAlphaComponent(0.3)
		control.isUserInteractionEnabled = false
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()

	private let actionButton: UIButton = {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = String(localized: "onboarding.actionButton")
		config.baseBackgroundColor = .ypFixedBlack
		config.baseForegroundColor = .ypFixedWhite
		config.background.cornerRadius = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
		button.configuration = config
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	init(viewModel: OnboardingViewModel = OnboardingViewModel()) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		bindViewModel()
		configureInitialState()
		viewModel.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		AppAnalytics.shared.open(.onboarding)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		AppAnalytics.shared.close(.onboarding)
	}

	private func setupViews() {
		pageControl.numberOfPages = pageViewControllers.count

		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.didMove(toParent: self)

		view.addSubview(pageControl)
		view.addSubview(actionButton)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
			pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			actionButton.heightAnchor.constraint(equalToConstant: 60),

			pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -24)
		])
	}

	private func setupActions() {
		actionButton.addAction(UIAction { [weak self] _ in
			AppAnalytics.shared.click(.onboarding, item: .onboardingAction)
			self?.viewModel.didTapActionButton()
		}, for: .touchUpInside)
	}

	private func bindViewModel() {
		viewModel.currentPagePublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] pageIndex in
				self?.pageControl.currentPage = pageIndex
			}
			.store(in: &cancellables)

		viewModel.finishPublisher
			.receive(on: RunLoop.main)
			.sink { [weak self] in
				self?.onFinish?()
			}
			.store(in: &cancellables)
	}

	private func configureInitialState() {
		guard let firstPage = pageViewControllers.first else { return }
		pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
	}
}

extension OnboardingViewController: UIPageViewControllerDataSource {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard
			let vc = viewController as? OnboardingPageContentViewController,
			let currentIndex = pageViewControllers.firstIndex(where: { $0 === vc }),
			currentIndex > 0
		else {
			return nil
		}

		return pageViewControllers[currentIndex - 1]
	}

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard
			let vc = viewController as? OnboardingPageContentViewController,
			let currentIndex = pageViewControllers.firstIndex(where: { $0 === vc }),
			currentIndex < pageViewControllers.count - 1
		else {
			return nil
		}

		return pageViewControllers[currentIndex + 1]
	}
}

extension OnboardingViewController: UIPageViewControllerDelegate {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		didFinishAnimating finished: Bool,
		previousViewControllers: [UIViewController],
		transitionCompleted completed: Bool
	) {
		guard
			finished,
			completed,
			let currentVC = pageViewController.viewControllers?.first as? OnboardingPageContentViewController,
			let pageIndex = pageViewControllers.firstIndex(where: { $0 === currentVC })
		else {
			return
		}

		viewModel.didFinishTransition(to: pageIndex)
	}
}
