//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Codex on 19.02.26.
//

import UIKit

final class OnboardingViewController: UIViewController {
	var onFinish: (() -> Void)?

	private let pages: [OnboardingPage] = [
		OnboardingPage(
			title: "Отслеживайте только\nто, что хотите",
			backgroundImageName: "OnboardingBackgroundBlue",
			fallbackTopColor: UIColor(red: 0.28, green: 0.46, blue: 0.87, alpha: 1.0),
			fallbackBottomColor: UIColor(red: 0.90, green: 0.93, blue: 0.98, alpha: 1.0)
		),
		OnboardingPage(
			title: "Даже если это\nне литры воды и йога",
			backgroundImageName: "OnboardingBackgroundRed",
			fallbackTopColor: UIColor(red: 0.94, green: 0.43, blue: 0.46, alpha: 1.0),
			fallbackBottomColor: UIColor(red: 0.96, green: 0.88, blue: 0.89, alpha: 1.0)
		)
	]

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
		pages.map { OnboardingPageContentViewController(page: $0) }
	}()

	private let pageControl: UIPageControl = {
		let control = UIPageControl()
		control.numberOfPages = 0
		control.currentPage = 0
		control.currentPageIndicatorTintColor = .ypBlack
		control.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
		control.isUserInteractionEnabled = false
		control.translatesAutoresizingMaskIntoConstraints = false
		return control
	}()

	private let actionButton: UIButton = {
		let button = UIButton(type: .system)
		var config = UIButton.Configuration.filled()
		config.title = "Вот это технологии!"
		config.baseBackgroundColor = .ypBlack
		config.baseForegroundColor = .ypWhite
		config.background.cornerRadius = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 16, bottom: 18, trailing: 16)
		button.configuration = config
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private var currentPageIndex = 0

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
		setupActions()
		configureInitialState()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: false)
	}

	private func setupViews() {
		pageControl.numberOfPages = pages.count

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
			self?.handleActionButtonTap()
		}, for: .touchUpInside)
	}

	private func configureInitialState() {
		guard let firstPage = pageViewControllers.first else { return }
		currentPageIndex = 0
		pageControl.currentPage = 0
		pageViewController.setViewControllers([firstPage], direction: .forward, animated: false)
	}

	private func handleActionButtonTap() {
		onFinish?()
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

		currentPageIndex = pageIndex
		pageControl.currentPage = pageIndex
	}
}

#Preview {
	OnboardingViewController()
}
